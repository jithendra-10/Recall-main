import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';
import '../future_calls/gmail_sync_future_call.dart';
import '../utils/rate_limiter.dart';
import '../utils/encryption_helper.dart';
import 'package:dotenv/dotenv.dart';

class DashboardEndpoint extends Endpoint {
  // Don't require login - we'll check manually or use demo data
  @override
  bool get requireLogin => false;

  /// Get complete dashboard data
  Future<DashboardData> getDashboardData(Session session) async {
    // Rate Limit Check
    final clientIp = session.authenticated?.userIdentifier ?? 'unauthenticated';
    if (!RateLimiter.isAllowed(clientIp, limit: 20, window: const Duration(minutes: 1))) {
       throw Exception('Rate limit exceeded');
    }

    try {
      // Enforce authentication
      final userIdentifier = session.authenticated?.userIdentifier;
      if (userIdentifier == null) {
        throw Exception('User authentication required.');
      }
      final userId = int.parse(userIdentifier);

      // Get user config for sync status
      final userConfig = await UserConfig.db.findFirstRow(
        session,
        where: (t) => t.userInfoId.equals(userId),
      );

      // AUTO-SYNC: If user has token but never synced (or manually cleared), trigger sync now
      bool autoSyncTriggered = false;
      if (userConfig != null && 
          userConfig.googleRefreshToken != null && 
          (userConfig.lastSyncTime == null || 
           DateTime.now().toUtc().difference(userConfig.lastSyncTime!).inMinutes > 3)) {
        session.log('getDashboardData: Auto-triggering first sync for userId=$userId', level: LogLevel.info);
        autoSyncTriggered = true;
        // Run sync in background (don't await to avoid blocking dashboard load)
        _triggerSyncInternal(session, userId).catchError((e) {
          session.log('getDashboardData: Background sync error: $e', level: LogLevel.warning);
        });
      }

      // Get recent interactions for memory feed
      final nudgeContact = await Contact.db.findFirstRow(
        session,
        where: (t) => t.ownerId.equals(userId),
        orderBy: (t) => t.healthScore,
        orderDescending: false,
      );

      // Calculate days silent for nudge contact
      int? nudgeDaysSilent;
      String? nudgeLastTopic;
      if (nudgeContact != null && nudgeContact.lastContacted != null) {
        nudgeDaysSilent = DateTime.now().toUtc().difference(nudgeContact.lastContacted!).inDays;
        
        // Get last interaction topic
        final lastInteraction = await Interaction.db.findFirstRow(
          session,
          where: (t) => t.ownerId.equals(userId) & t.contactId.equals(nudgeContact.id!),
          orderBy: (t) => t.date,
          orderDescending: true,
        );
        nudgeLastTopic = lastInteraction?.snippet;
      }

      // Get recent interactions for memory feed
      final recentInteractionsRaw = await Interaction.db.find(
        session,
        where: (t) => t.ownerId.equals(userId),
        orderBy: (t) => t.date,
        orderDescending: true,
        limit: 10,
        include: Interaction.include(contact: Contact.include()),
      );

      final recentInteractions = recentInteractionsRaw.map((i) => InteractionSummary(
        contactName: i.contact?.name ?? i.contact?.email ?? 'Unknown',
        contactEmail: i.contact?.email ?? '',
        contactAvatarUrl: i.contact?.avatarUrl,
        summary: i.snippet,
        subject: i.subject,
        body: i.body,
        timestamp: i.date,
        type: i.type,
      )).toList();

      // Get top contacts by health score
      final topContacts = await Contact.db.find(
        session,
        where: (t) => t.ownerId.equals(userId),
        orderBy: (t) => t.healthScore,
        orderDescending: true,
        limit: 5,
      );

      // Count total contacts and drifting
      final allContacts = await Contact.db.find(
        session,
        where: (t) => t.ownerId.equals(userId),
      );
      final totalContacts = allContacts.length;
      final driftingCount = allContacts.where((c) => c.healthScore < 50).length;

      return DashboardData(
        lastSyncTime: userConfig?.lastSyncTime,
        isSyncing: (userConfig?.isSyncing ?? false) || autoSyncTriggered,
        nudgeContact: nudgeContact,
        nudgeDaysSilent: nudgeDaysSilent,
        nudgeLastTopic: nudgeLastTopic,
        recentInteractions: recentInteractions,
        topContacts: topContacts,
        totalContacts: totalContacts,
        driftingCount: driftingCount,
      );
    } catch (e, stack) {
      session.log('Dashboard error: $e', level: LogLevel.error, stackTrace: stack);
      // Return empty state on error
      return DashboardData(
        lastSyncTime: null,
        isSyncing: false,
        nudgeContact: null,
        nudgeDaysSilent: null,
        nudgeLastTopic: null,
        recentInteractions: [],
        topContacts: [],
        totalContacts: 0,
        driftingCount: 0,
      );
    }
  }

  /// Get all contacts for the user
  Future<List<Contact>> getContacts(Session session) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) {
       print('getContacts: No user authenticated. Returning empty.');
       return [];
    }
    
    final userId = int.parse(userIdentifier);
    
    print('getContacts called for userId: $userId');

    return Contact.db.find(
      session,
      where: (t) => t.ownerId.equals(userId),
      orderBy: (t) => t.healthScore,
      orderDescending: true,
    );
  }

  /// Get interactions for a specific contact
  Future<List<InteractionSummary>> getContactInteractions(
    Session session,
    int contactId,
  ) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return [];
    
    final userId = int.parse(userIdentifier);

    final interactions = await Interaction.db.find(
      session,
      where: (t) => t.ownerId.equals(userId) & t.contactId.equals(contactId),
      orderBy: (t) => t.date,
      orderDescending: true,
      limit: 20,
      include: Interaction.include(contact: Contact.include()),
    );

    return interactions.map((i) => InteractionSummary(
      contactName: i.contact?.name ?? i.contact?.email ?? 'Unknown',
      contactEmail: i.contact?.email ?? '',
      summary: i.snippet,
      timestamp: i.date,
      type: i.type,
    )).toList();
  }

  /// Trigger manual sync - gets userId from session
  Future<void> triggerSync(Session session) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) throw Exception('User not authenticated');
    final userId = int.parse(userIdentifier);
    await _triggerSyncInternal(session, userId);
  }

  /// Internal sync trigger that accepts userId directly (for unauthenticated contexts)
  Future<void> _triggerSyncInternal(Session session, int userId) async {
    session.log('_triggerSyncInternal: Scheduling sync for userId=$userId', level: LogLevel.info);
    
    final userConfig = await UserConfig.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(userId),
    );

    if (userConfig == null || userConfig.googleRefreshToken == null) {
      session.log('_triggerSyncInternal: No Gmail connection for userId=$userId', level: LogLevel.warning);
      return;
    }

    // Set syncing status to true immediately for UI feedback
    userConfig.isSyncing = true;
    await UserConfig.db.updateRow(session, userConfig);

    // Schedule the future call to run safely in background (detached from this HTTP session)
    // passing userConfig object as the payload (it is SerializableEntity)
    // Using registered name 'gmail_sync' from server.dart
    await Serverpod.instance!.futureCallWithDelay(
      'gmail_sync',
      userConfig,
      const Duration(seconds: 0),
    );
  }


  /// Exchange auth code for refresh token and store it
  /// Returns detailed error info on failure for debugging
  Future<bool> exchangeAndStoreGmailToken(Session session, String authCode, int userId) async {
    if (userId <= 0) {
      session.log('exchangeAndStoreGmailToken: Invalid userId=$userId', level: LogLevel.error);
      return false;
    }

    session.log('exchangeAndStoreGmailToken: Starting for userId=$userId, authCode length=${authCode.length}', level: LogLevel.info);

    try {
      // 1. Load Client Secret from Environment
      // Use DotEnv to ensure we get values loaded in main/server
      final env = DotEnv(includePlatformEnvironment: true)..load();
      final clientId = env['GOOGLE_CLIENT_ID'];
      final clientSecret = env['GOOGLE_CLIENT_SECRET'];

      if (clientId == null || clientSecret == null) {
        session.log('exchangeAndStoreGmailToken: Missing GOOGLE_CLIENT_ID or GOOGLE_CLIENT_SECRET in .env', level: LogLevel.error);
        return false;
      }
      
      session.log('exchangeAndStoreGmailToken: Using clientId=${clientId.substring(0, 5)}...', level: LogLevel.info);

      // 2. Manual OAuth token exchange with detailed error logging
      final httpClient = http.Client();
      try {
        final response = await httpClient.post(
          Uri.parse('https://oauth2.googleapis.com/token'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'code': authCode,
            'client_id': clientId,
            'client_secret': clientSecret,
            'grant_type': 'authorization_code',
            // No redirect_uri for native Android serverAuthCode flows
          },
        );

        session.log('exchangeAndStoreGmailToken: Google response status=${response.statusCode}', level: LogLevel.info);
        
        if (response.statusCode != 200) {
          // Log the full error for debugging
          session.log('exchangeAndStoreGmailToken: FAILED - ${response.body}', level: LogLevel.error);
          
          // Parse Google's error response
          try {
            final errorJson = jsonDecode(response.body);
            final error = errorJson['error'] ?? 'unknown';
            final errorDesc = errorJson['error_description'] ?? 'no description';
            session.log('exchangeAndStoreGmailToken: Error=$error, Description=$errorDesc', level: LogLevel.error);
            
            // Common errors:
            // - "invalid_grant" = code already used or expired
            // - "redirect_uri_mismatch" = wrong redirect URI
            // - "invalid_client" = wrong client credentials
          } catch (_) {}
          
          return false;
        }

        final tokenData = jsonDecode(response.body);
        final refreshToken = tokenData['refresh_token'] as String?;
        final accessToken = tokenData['access_token'] as String?;
        final expiresIn = tokenData['expires_in'];

        session.log('exchangeAndStoreGmailToken: accessToken=${accessToken != null}, refreshToken=${refreshToken != null}, expiresIn=$expiresIn', level: LogLevel.info);

        if (refreshToken == null) {
          session.log(
            'exchangeAndStoreGmailToken: No refresh_token returned! '
            'This happens when the user has previously authorized the app. '
            'User should revoke access at https://myaccount.google.com/permissions and try again.',
            level: LogLevel.warning
          );
          return false;
        }

        // 3. Store Token
        await _storeRefreshTokenInternal(session, userId, refreshToken);
        session.log('exchangeAndStoreGmailToken: SUCCESS - Token stored for userId=$userId', level: LogLevel.info);
        
        // 4. Trigger immediate sync
        try {
          await _triggerSyncInternal(session, userId);
        } catch (e) {
          session.log('exchangeAndStoreGmailToken: Sync trigger failed but token stored: $e', level: LogLevel.warning);
        }
        
        return true;
        
      } finally {
        httpClient.close();
      }
    } catch (e, stack) {
      session.log('exchangeAndStoreGmailToken: Exception - $e', level: LogLevel.error, stackTrace: stack);
      return false;
    }
  }


  /// Internal helper to store token
  Future<void> _storeRefreshTokenInternal(Session session, int userId, String refreshToken) async {
    var userConfig = await UserConfig.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(userId),
    );

    if (userConfig == null) {
      userConfig = UserConfig(
        userInfoId: userId,
        googleRefreshToken: EncryptionHelper.encrypt(refreshToken),
        lastSyncTime: null, // Reset sync time to trigger fresh sync
        dailyBriefingTime: 8,
        isPro: false,
        driftingAlertsEnabled: true,
        weeklyDigestEnabled: true,
        newMemoryAlertsEnabled: true,
      );
      await UserConfig.db.insertRow(session, userConfig);
    } else {
      userConfig.googleRefreshToken = EncryptionHelper.encrypt(refreshToken);
      // Don't update lastSyncTime here, let triggerSync or the sync job handle it
      await UserConfig.db.updateRow(session, userConfig);
    }
  }

  /// Store refresh token manually (legacy/debug)
  Future<void> storeRefreshToken(Session session, String refreshToken) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return;
    await _storeRefreshTokenInternal(session, int.parse(userIdentifier), refreshToken);
  }

  Future<SetupStatus> getSetupStatus(Session session, {int? userId}) async {
    // Try to get authenticated user, or use provided userId
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) {
      // Return empty status or throw, assuming setup requires auth
      return SetupStatus(
        hasToken: false,
        emailCount: 0,
        interactionCount: 0,
        isSyncing: false,
      );
    }
    final userId = int.parse(userIdentifier);

    final userConfig = await UserConfig.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(userId),
    );

    final interactionCount = await Interaction.db.count(
      session,
      where: (t) => t.ownerId.equals(userId),
    );

    return SetupStatus(
      hasToken: userConfig?.googleRefreshToken != null,
      emailCount: 0, 
      interactionCount: interactionCount,
      isSyncing: userConfig?.lastSyncTime == null && userConfig?.googleRefreshToken != null,
    );
  }

  /// Get agenda items for a specific date range
  Future<List<AgendaItem>> getAgendaItems(Session session, DateTime start, DateTime end) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return [];
    final userId = int.parse(userIdentifier);

    return AgendaItem.db.find(
      session,
      where: (t) => t.ownerId.equals(userId) & 
                    t.startTime.between(start, end),
      orderBy: (t) => t.startTime,
      include: AgendaItem.include(
        contact: Contact.include(), // Include contact details for avatars
      ),
    );
  }
}
