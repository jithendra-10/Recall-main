import 'dart:io';
import 'dart:convert';
import 'package:dotenv/dotenv.dart';
import 'package:serverpod/serverpod.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';
import '../services/gemini_service.dart';
import '../utils/encryption_helper.dart';

class GmailSyncFutureCall extends FutureCall {
  // Load credentials from config file
  static late String _clientId;
  static late String _clientSecret;
  static bool _credentialsLoaded = false;

  static Future<void> _loadCredentials() async {
    if (_credentialsLoaded) return;
    
    // Try environment variables first
    final env = DotEnv(includePlatformEnvironment: true);
    if (env.isDefined('GOOGLE_CLIENT_ID') && env.isDefined('GOOGLE_CLIENT_SECRET')) {
      _clientId = env['GOOGLE_CLIENT_ID']!;
      _clientSecret = env['GOOGLE_CLIENT_SECRET']!;
      _credentialsLoaded = true;
      return;
    }

    // Fallback to JSON file
    try {
      final configFile = File('config/google_client_secret.json');
      if (await configFile.exists()) {
        final configJson = jsonDecode(await configFile.readAsString());
        final data = configJson['installed'] ?? configJson['web'];
        _clientId = data['client_id'];
        _clientSecret = data['client_secret'];
        _credentialsLoaded = true;
      } else {
        throw Exception('Credentials not found in .env or config/google_client_secret.json');
      }
    } catch (e) {
      throw Exception('Failed to load Google credentials: $e');
    }
  }

  @override
  Future<void> invoke(Session session, dynamic object) async {
    session.log('Starting Gmail Sync...', level: LogLevel.info);

    await _loadCredentials();

    // Check if we are syncing a specific user
    int? targetedUserId;
    if (object is UserConfig) {
      targetedUserId = object.userInfoId;
      session.log('Targeting specific user via UserConfig: $targetedUserId', level: LogLevel.info);
    } else if (object is int) {
      // Fallback if int is somehow allowed in future versions
      targetedUserId = object;
    }

    // Fetch users with a Google Refresh Token
    final users = await UserConfig.db.find(
      session,
      where: (t) => t.googleRefreshToken.notEquals(null) & 
                   (targetedUserId != null ? t.userInfoId.equals(targetedUserId) : Constant.bool(true)),
    );

    session.log('Found ${users.length} users with Gmail tokens', level: LogLevel.info);

    for (var userConfig in users) {
      try {
        await _syncUser(session, userConfig);
      } catch (e, stack) {
        session.log(
          'Failed to sync user ${userConfig.userInfoId}: $e',
          level: LogLevel.error,
          exception: e,
          stackTrace: stack,
        );
      }
    }
  }

  Future<void> _syncUser(Session session, UserConfig userConfig) async {
    final encryptedToken = userConfig.googleRefreshToken!;
    final refreshToken = EncryptionHelper.decrypt(encryptedToken);

    if (refreshToken.isEmpty) {
        session.log('Failed to decrypt token for user ${userConfig.userInfoId}', level: LogLevel.error);
        return;
    }
    
    session.log('Syncing user ${userConfig.userInfoId}...', level: LogLevel.info);

    final credentials = AccessCredentials(
      AccessToken('Bearer', '', DateTime.now().toUtc().subtract(const Duration(hours: 1))),
      refreshToken,
      ['https://www.googleapis.com/auth/gmail.readonly'],
    );

    final authClient = autoRefreshingClient(
      ClientId(_clientId, _clientSecret),
      credentials,
      http.Client(),
    );

    try {
      final gmailApi = gmail.GmailApi(authClient);

      // Build query for incremental sync
      print('DEBUG: Gmail Sync STARTED for user ${userConfig.userInfoId}');
      
      // Build query for incremental sync
      String q = 'in:inbox OR in:sent';
      
      // FORCE SYNC FIX: Always fetch last 60 days to ensure data backfill
      // if (userConfig.lastSyncTime != null) {
      //   final seconds = userConfig.lastSyncTime!.millisecondsSinceEpoch ~/ 1000;
      //   q = '$q after:$seconds';
      // } else {
      
      print('DEBUG: Forcing 60-day sync for data backfill');
      session.log("Forcing 60-day sync for data backfill", level: LogLevel.info);
      q = '$q newer_than:60d';
      
      // }

      String? pageToken;
      do {
        final listResponse = await gmailApi.users.messages.list(
          'me',
          q: q,
          maxResults: 100, // Process in batches
          pageToken: pageToken,
        );
        
        pageToken = listResponse.nextPageToken;

        if (listResponse.messages != null) {
           // ... processing loop (see below)
           session.log('Processing batch of ${listResponse.messages!.length} messages', level: LogLevel.info);
           for (var msg in listResponse.messages!) {
             // ... existing processing logic ...
             try {
                final message = await gmailApi.users.messages.get('me', msg.id!, format: 'full');
                if (_shouldFilterEmail(message)) continue;
                await _processEmail(session, userConfig, message);
             } catch (e) {
                session.log('Error processing message ${msg.id}: $e', level: LogLevel.warning);
             }
           }
        }
      } while (pageToken != null);



      // Update health scores for all contacts
      await _updateHealthScores(session, userConfig.userInfoId);

      // Update sync time
      userConfig.lastSyncTime = DateTime.now().toUtc();
      await UserConfig.db.updateRow(session, userConfig);

      session.log('Sync completed for user ${userConfig.userInfoId}', level: LogLevel.info);

      session.log('Sync completed for user ${userConfig.userInfoId}', level: LogLevel.info);

    } finally {
      authClient.close();
      
      // Reset isSyncing flag
      // Reload config to ensure we don't overwrite other parallel changes
      try {
        final currentConfig = await UserConfig.db.findFirstRow(
          session,
          where: (t) => t.id.equals(userConfig.id),
        );
        if (currentConfig != null) {
          currentConfig.isSyncing = false;
          // Also persist lastSyncTime if we set it in the try block (userConfig object might have it)
          if (userConfig.lastSyncTime != null && currentConfig.lastSyncTime == null) {
             currentConfig.lastSyncTime = userConfig.lastSyncTime;
          }
          await UserConfig.db.updateRow(session, currentConfig);
        }
      } catch (e) {
        session.log('Failed to reset isSyncing flag: $e', level: LogLevel.error);
      }
    }
  }

  bool _shouldFilterEmail(gmail.Message message) {
    final labels = message.labelIds ?? [];
    
    // Filter spam and specific categories
    // User requested: "except automation mails, remaiing all mailes should be show"
    // We interpret "automation" as Social, Updates, and Forums. Promotions are often semi-automated but might be desired?
    // Let's filter strict automation categories.
    if (labels.contains('SPAM') || 
        labels.contains('CATEGORY_SOCIAL') ||
        labels.contains('CATEGORY_UPDATES') ||
        labels.contains('CATEGORY_FORUMS')) {
      return true;
    }
    // Note: We are ALLOWING 'CATEGORY_PROMOTIONS' for now as they might not be "automation" in the user's mind, 
    // or we can add it to the list if "automation" implies all non-personal. 
    // Safest bet for "automation" is Updates (transactional) and Social.

    // Filter by subject patterns (OTPs, automated messages)
    final subject = _getHeader(message, 'Subject')?.toLowerCase() ?? '';
    final filterPatterns = [
      'otp', 'verification code', 'security code', 'one-time',
      'noreply', 'no-reply', 'do not reply', 'automated',
      'unsubscribe', 'newsletter', 'digest', 'notification',
    ];
    
    for (final pattern in filterPatterns) {
      if (subject.contains(pattern)) return true;
    }

    // Filter by sender patterns
    final from = _getHeader(message, 'From')?.toLowerCase() ?? '';
    final senderFilters = [
      'noreply@', 'no-reply@', 'notifications@', 'support@',
      'info@', 'news@', 'updates@', 'mailer@', 'postmaster@',
    ];
    
    for (final pattern in senderFilters) {
      if (from.contains(pattern)) return true;
    }

    return false;
  }

  String? _getHeader(gmail.Message message, String name) {
    final headers = message.payload?.headers;
    if (headers == null) return null;
    
    for (var h in headers) {
      if (h.name?.toLowerCase() == name.toLowerCase()) return h.value;
    }
    return null;
  }

  Future<void> _processEmail(Session session, UserConfig userConfig, gmail.Message message) async {
    final from = _getHeader(message, 'From');
    final to = _getHeader(message, 'To');
    final subject = _getHeader(message, 'Subject') ?? '';
    final dateStr = _getHeader(message, 'Date');
    
    if (from == null) return;

    // Determine if sent or received
    final labels = message.labelIds ?? [];
    final isSent = labels.contains('SENT');
    
    // Get contact email address
    final contactString = isSent ? (to ?? 'Unknown') : from;
    if (contactString.isEmpty) return;

    // Parse email address
    final emailRegex = RegExp(r'<(.+)>');
    final match = emailRegex.firstMatch(contactString);
    final emailAddress = match?.group(1) ?? contactString.trim();
    final name = match != null ? contactString.substring(0, match.start).trim().replaceAll('"', '') : null;

    // Skip self-emails
    if (emailAddress == _getHeader(message, isSent ? 'From' : 'To')) return;

    // Find or create contact
    var contact = await Contact.db.findFirstRow(
      session,
      where: (t) => t.ownerId.equals(userConfig.userInfoId) & t.email.equals(emailAddress),
    );

    if (contact == null) {
      contact = Contact(
        ownerId: userConfig.userInfoId,
        email: emailAddress,
        name: name,
        healthScore: 100.0,
        tier: 2,
      );
      contact = await Contact.db.insertRow(session, contact);
    } else if (name != null && (contact.name == null || contact.name!.isEmpty)) {
      contact.name = name;
      await Contact.db.updateRow(session, contact);
    }

    // Ensure we have a valid contact ID
    final contactId = contact.id;
    if (contactId == null) {
      session.log('Failed to get contact ID', level: LogLevel.error);
      return;
    }

    // Parse date
    DateTime emailDate;
    try {
      emailDate = _parseEmailDate(dateStr ?? '');
    } catch (_) {
      emailDate = DateTime.now().toUtc();
    }

    // Check for duplicate
    final existing = await Interaction.db.findFirstRow(
      session,
      where: (t) => t.ownerId.equals(userConfig.userInfoId) & 
                    t.contactId.equals(contactId) &
                    t.date.equals(emailDate),
    );
    
    if (existing != null) return; // Skip duplicate

    // Extract full email body
    final body = _extractBody(message);
    final contentToAnalyze = body.isNotEmpty ? body : (message.snippet ?? subject);
    
    if (contentToAnalyze.length < 20) {
      session.log('Email too short to analyze: ${message.id}', level: LogLevel.debug);
      return;
    }

    // Use Gemini to analyze the email
    session.log('Analyzing email with Gemini...', level: LogLevel.debug);
    
    final analysis = await GeminiService.analyzeEmail(
      contentToAnalyze,
      from,
      to ?? 'Unknown',
      isSent,
      emailDate,
    );
    
    if (analysis == null) {
      session.log('Email ignored by AI logic: ${message.id} - Saving as raw interaction anyway', level: LogLevel.info);
      // Fallback: Create interaction without AI tags so it at least appears
      // Use snippet as summary
      await _createRawInteraction(session, userConfig, contact, emailDate, subject, body, isSent, message.snippet ?? body);
      return;
    }

    final summary = analysis['summary'] as String? ?? 'No summary available';
    final tags = (analysis['intent_tags'] as List? ?? []).join(', ');
    final followUp = analysis['needs_follow_up'] == true ? '[Follow-up]' : '';
    
    final formattedSnippet = tags.isNotEmpty 
        ? '$summary\n\nTags: $tags $followUp'.trim()
        : summary;

    // Generate vector embedding
    session.log('Generating embedding...', level: LogLevel.debug);
    final embeddingList = await GeminiService.generateEmbedding(summary);
    
    // Ensure 768 dimensions
    final paddedEmbedding = embeddingList.length >= 768 
        ? embeddingList.sublist(0, 768) 
        : [...embeddingList, ...List.filled(768 - embeddingList.length, 0.0)];

    // Create interaction
    final interaction = Interaction(
      ownerId: userConfig.userInfoId,
      contactId: contact.id!,
      date: emailDate,
      snippet: formattedSnippet,
      subject: subject,
      body: body,
      type: isSent ? 'email_out' : 'email_in',
      embedding: Vector(paddedEmbedding),
    );

    final savedInteraction = await Interaction.db.insertRow(session, interaction);

    // Update contact last contacted
    if (contact.lastContacted == null || emailDate.isAfter(contact.lastContacted!)) {
      contact.lastContacted = emailDate;
      await Contact.db.updateRow(session, contact);
    }

    // --- SMART AGENDA LOGIC ---
    // Check if an event was extracted and create AgendaItem
    final eventData = analysis['extracted_event'] as Map<String, dynamic>?;
    if (eventData != null && eventData['found'] == true) {
      try {
        final title = eventData['title'] as String? ?? 'Scheduled Interaction';
        final startTimeStr = eventData['start_time'] as String?;
        final endTimeStr = eventData['end_time'] as String?;
        final priority = eventData['priority'] as String? ?? 'normal';
        
        if (startTimeStr != null) {
          final startTime = DateTime.parse(startTimeStr);
          final endTime = endTimeStr != null ? DateTime.parse(endTimeStr) : startTime.add(const Duration(hours: 1));
          
          final agendaItem = AgendaItem(
            ownerId: userConfig.userInfoId,
            contactId: contact.id!, // Link to the contact
            interactionId: savedInteraction.id, // Link to the source email
            title: title,
            description: summary, // Use the AI summary as context
            startTime: startTime,
            endTime: endTime,
            priority: priority,
            status: 'pending',
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          );
          
          await AgendaItem.db.insertRow(session, agendaItem);
          session.log('Extracted Agenda Item: $title at $startTime', level: LogLevel.info);
        }
      } catch (e) {
        session.log('Failed to create AgendaItem: $e', level: LogLevel.warning);
      }
    }
  }

  String _extractBody(gmail.Message message) {
    if (message.payload == null) return '';
    return _findBody(message.payload!) ?? message.snippet ?? '';
  }

  String? _findBody(gmail.MessagePart part) {
    if (part.mimeType == 'text/plain' && part.body?.data != null) {
      try {
        return utf8.decode(base64.decode(part.body!.data!));
      } catch (e) {
        // Try loose decoding or fallback
        return null; 
      }
    }
    
    if (part.parts != null) {
      for (final subPart in part.parts!) {
        final body = _findBody(subPart);
        if (body != null) return body;
      }
    }
    return null;
  }

  DateTime _parseEmailDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime.now().toUtc();
    }
  }

  Future<void> _updateHealthScores(Session session, int userId) async {
    final contacts = await Contact.db.find(
      session,
      where: (t) => t.ownerId.equals(userId),
    );

    final now = DateTime.now().toUtc();

    for (var contact in contacts) {
      double score = 100.0;
      
      if (contact.lastContacted != null) {
        final daysSilent = now.difference(contact.lastContacted!).inDays;
        
        // Tier-based thresholds
        final thresholds = {1: 30, 2: 90, 3: 365};
        final threshold = thresholds[contact.tier] ?? 90;
        
        score = ((threshold - daysSilent) / threshold * 100).clamp(0, 100);
      }

      contact.healthScore = score;
      await Contact.db.updateRow(session, contact);
    }
  }
  Future<void> _createRawInteraction(
      Session session, 
      UserConfig userConfig, 
      Contact contact, 
      DateTime date, 
      String subject, 
      String body, 
      bool isSent, 
      String snippet,
  ) async {
      // 768-dim zero vector
      final zeroEmbedding = List.filled(768, 0.0);
      
      final interaction = Interaction(
        ownerId: userConfig.userInfoId,
        contactId: contact.id!,
        date: date,
        snippet: snippet,
        subject: subject,
        body: body,
        type: isSent ? 'email_out' : 'email_in',
        embedding: Vector(zeroEmbedding),
      );

      await Interaction.db.insertRow(session, interaction);
      
      // Update contact last contacted
      if (contact.lastContacted == null || date.isAfter(contact.lastContacted!)) {
        contact.lastContacted = date;
        await Contact.db.updateRow(session, contact);
      }
  }
}
