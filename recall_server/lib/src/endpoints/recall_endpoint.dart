import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/gemini_service.dart';
import '../utils/rate_limiter.dart';
import '../utils/input_validator.dart';

class RecallEndpoint extends Endpoint {
  // Don't require login - we'll handle gracefully
  @override
  bool get requireLogin => false;

  /// Get list of chat sessions for the user
  Future<List<ChatSession>> getChatSessions(Session session, {int limit = 20}) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return [];
    final userId = int.parse(userIdentifier);

    return ChatSession.db.find(
      session,
      where: (t) => t.ownerId.equals(userId),
      orderBy: (t) => t.updatedAt,
      orderDescending: true,
      limit: limit,
    );
  }

  /// Get messages for a specific session
  Future<List<ChatMessage>> getChatMessages(Session session, {required int chatSessionId, int limit = 50}) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return [];
    final userId = int.parse(userIdentifier);

    return ChatMessage.db.find(
      session,
      where: (t) => t.chatSessionId.equals(chatSessionId) & t.ownerId.equals(userId),
      orderBy: (t) => t.timestamp,
      orderDescending: false, // Oldest first
      limit: limit,
    );
  }

  /// Ask RECALL - RAG-powered question answering with Gemini
  Future<ChatMessage> askRecall(Session session, String query, {int? chatSessionId}) async {
    // 2. Input Validation
    try {
      InputValidator.validateQuery(query);
    } catch (e) {
      return ChatMessage(
         chatSessionId: 0, 
         ownerId: 0, 
         role: 'system', 
         content: 'Invalid input provided.', 
         timestamp: DateTime.now().toUtc()
       );
    }

    try {
      // Enforce authentication (with Dev Fallback)
      int userId;
      final userIdentifier = session.authenticated?.userIdentifier;
      if (userIdentifier != null) {
        userId = int.parse(userIdentifier);
      } else {
        session.log('WARNING: askRecall called without auth. Defaulting to userId=1 for dev/demo.', level: LogLevel.warning);
        userId = 1; 
      }

      session.log('Ask RECALL query: $query (Session: $chatSessionId)', level: LogLevel.info);

      // 0. Get or Create Session
      ChatSession? sessionObj;
      
      if (chatSessionId != null) {
        sessionObj = await ChatSession.db.findById(session, chatSessionId);
      }
      
      if (sessionObj == null) {
         sessionObj = ChatSession(
          ownerId: userId,
          title: _generateTitle(query), 
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        );
        sessionObj = await ChatSession.db.insertRow(session, sessionObj);
      } else {
        // Update title if it's the generic one and this is early
        if (sessionObj.title == 'General Chat' || sessionObj.title == 'New Chat' || sessionObj.title == 'Chat') {
           sessionObj.title = _generateTitle(query);
           await ChatSession.db.updateRow(session, sessionObj);
        }
      }
      
      final sessionId = sessionObj.id!;

      // 1. Persist User Message
      await ChatMessage.db.insertRow(
        session,
        ChatMessage(
          chatSessionId: sessionId,
          ownerId: userId,
          role: 'user',
          content: query,
          timestamp: DateTime.now().toUtc(),
        ),
      );

      // --- BUTLER LOGIC START ---

      // 2. Greeting Check
      final greetings = ['hi', 'hello', 'hey', 'good morning', 'good afternoon', 'good evening'];
      final isGreeting = greetings.any((w) => query.toLowerCase().startsWith(w)) && query.length < 20;

      List<String> contextList = [];
      List<String> sources = [];

      // 3. Gather Context
      
      // A. DASHBOARD STATS
      final allContactsCount = await Contact.db.count(session, where: (t) => t.ownerId.equals(userId));
      final driftingCount = await Contact.db.count(session, where: (t) => t.ownerId.equals(userId) & (t.healthScore < 50.0));
      contextList.add("Dashboard Status:\n- Total Contacts: $allContactsCount\n- Contacts Drifting: $driftingCount");

      // B. AGENDA
      final now = DateTime.now().toUtc();
      final todayStart = DateTime(now.year, now.month, now.day).toUtc();
      final tomorrowEnd = todayStart.add(const Duration(days: 2));
      final agendaItems = await AgendaItem.db.find(
        session,
        where: (t) => t.ownerId.equals(userId) & t.startTime.between(todayStart, tomorrowEnd),
        orderBy: (t) => t.startTime,
      );

      if (agendaItems.isNotEmpty) {
        contextList.add("Upcoming Agenda:");
        for (var a in agendaItems) {
           final note = a.description != null && a.description!.isNotEmpty ? " (Note: ${a.description})" : "";
           contextList.add("- ${a.title} at ${_formatDate(a.startTime)} (${a.priority})$note");
        }
      }

      // 4. Vector Search
      if (!isGreeting) {
        final queryEmbedding = await GeminiService.generateEmbedding(query);
        final embeddingString = '[${queryEmbedding.join(',')}]';
        final querySql = '''
          SELECT "id" 
          FROM "recall_interaction" 
          WHERE "ownerId" = $userId 
          ORDER BY "embedding" <=> '$embeddingString' 
          LIMIT 5
        ''';
        
        final result = await session.db.unsafeQuery(querySql);
        final ids = result.map((row) => row.first as int).toList();
        
        if (ids.isNotEmpty) {
           final interactions = await Interaction.db.find(
            session,
            where: (t) => t.id.inSet(ids.toSet()),
            include: Interaction.include(contact: Contact.include()),
          );
          
          if (interactions.isNotEmpty) {
            contextList.add("Relevant Email Memory:");
            contextList.addAll(interactions.map((m) {
              final contactName = m.contact?.name ?? m.contact?.email ?? 'Unknown';
              return '[$contactName]: ${m.snippet}';
            }));
            sources = interactions.map((m) => (m.contact?.name ?? 'Unknown') + " (${_formatDate(m.date)})").toSet().toList();
          }
        }
      }

      // 5. Generate Response
      final response = await GeminiService.generateRagResponse(
        query: query,
        retrievedContexts: contextList,
      );

      final assistantMessage = ChatMessage(
        chatSessionId: sessionId,
        ownerId: userId,
        role: 'assistant',
        content: response,
        timestamp: DateTime.now().toUtc(),
        sources: sources,
      );
      
      // 7. Persist Assistant Message
      await ChatMessage.db.insertRow(session, assistantMessage);
      
      // Update session timestamp
      sessionObj.updatedAt = DateTime.now().toUtc();
      await ChatSession.db.updateRow(session, sessionObj);

      return assistantMessage;

    } catch (e, stack) {
      session.log('Ask RECALL error: $e', level: LogLevel.error, stackTrace: stack);
      return ChatMessage(
        chatSessionId: 0,
        ownerId: 1,
        role: 'assistant',
        content: "I encountered an error: $e",
        timestamp: DateTime.now().toUtc(),
      );
    }
  }

  int _daysSilent(DateTime? date) {
    if (date == null) return 999;
    return DateTime.now().toUtc().difference(date).inDays;
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now().toUtc();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
    return '${diff.inDays ~/ 30} months ago';
  }

  /// Process voice note transcript
  Future<String> processVoiceNote(Session session, String transcript) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return "Authentication required used to process voice notes.";
    final userId = int.parse(userIdentifier);
    
    // Analyze
    final analysis = await GeminiService.analyzeVoiceNote(transcript, DateTime.now().toUtc());
    if (analysis == null) return "Failed to analyze voice note.";
    
    final summary = analysis['summary'] as String? ?? "Processed voice note.";
    final contactsData = analysis['contacts'] as List?;
    final agendaData = analysis['agenda_items'] as List?;
    
    final responseBuffer = StringBuffer();
    responseBuffer.writeln(summary);
    
    // Process Contacts
    if (contactsData != null) {
      for (var c in contactsData) {
        final name = c['name'];
        final isNew = c['is_new'] == true;
        final context = c['context'];
        
        if (isNew && name != null) {
          // Check if exists
          final existing = await Contact.db.findFirstRow(
            session, 
            where: (t) => t.ownerId.equals(userId) & t.name.ilike(name),
          );
          
          if (existing == null) {
            await Contact.db.insertRow(session, Contact(
              ownerId: userId,
              email: 'voice_${DateTime.now().millisecondsSinceEpoch}@recall.ai', // Placeholder
              name: name,
              healthScore: 50,
              lastContacted: DateTime.now().toUtc(),
              summary: context, 
            ));
            responseBuffer.writeln("\nAdded new contact: $name.");
          }
        }
      }
    }
    
    // Process Agenda
    if (agendaData != null) {
      for (var a in agendaData) {
        final title = a['title'];
        final startTimeStr = a['start_time'];
        final priority = a['priority'] ?? 'normal';
        
        if (title != null && startTimeStr != null) {
          final startTime = DateTime.tryParse(startTimeStr);
          if (startTime != null) {
            await AgendaItem.db.insertRow(session, AgendaItem(
              ownerId: userId,
              contactId: 0, // Placeholder
              title: title,
              description: "Voice Note: $transcript",
              startTime: startTime,
              priority: priority,
              status: 'pending',
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            ));
            responseBuffer.writeln("\nScheduled '$title' for ${_formatDate(startTime)}.");
          }
        }
      }
    }
    
    return responseBuffer.toString();
  }

  /// Generate AI draft email for a contact using Gemini
  Future<String> generateDraftEmail(Session session, int contactId, {int? clientReportedId}) async {
    int? userId;
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier != null) {
      userId = int.parse(userIdentifier);
    } else if (clientReportedId != null) {
      userId = clientReportedId;
      session.log('Using clientReportedId for generateDraftEmail: $userId', level: LogLevel.info);
    } else {
      // Fallback for debug/demo
      userId = 1;
      session.log('Fallback to userId 1 for generateDraftEmail', level: LogLevel.warning);
    }

    if (userId == null) return 'Please sign in to generate drafts.';

    final contact = await Contact.db.findById(session, contactId);
    if (contact == null || contact.ownerId != userId) {
      return 'Contact not found.';
    }

    final interactions = await Interaction.db.find(
      session,
      where: (t) => t.ownerId.equals(userId) & t.contactId.equals(contactId),
      orderBy: (t) => t.date,
      orderDescending: true,
      limit: 5,
    );

    final contactName = contact.name ?? 'there';
    final daysSilent = contact.lastContacted != null 
        ? DateTime.now().toUtc().difference(contact.lastContacted!).inDays
        : 30;
    final lastTopic = interactions.isNotEmpty ? interactions.first.snippet : 'our last conversation';
    final recentSnippets = interactions.map((i) => i.snippet).toList();

    final draft = await GeminiService.generateDraftEmail(
      contactName: contactName,
      lastTopic: lastTopic,
      daysSilent: daysSilent,
      recentInteractions: recentSnippets,
    );

    return draft;
  }

  String _generateTitle(String query) {
    if (query.length > 30) {
      return "${query.substring(0, 30)}...";
    }
    return query;
  }
}
