import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/gemini_service.dart';
import '../utils/rate_limiter.dart';
import '../utils/input_validator.dart';

class RecallEndpoint extends Endpoint {
  // Don't require login - we'll handle gracefully
  @override
  bool get requireLogin => false;

  /// Ask RECALL - RAG-powered question answering with Gemini
  Future<ChatMessage> askRecall(Session session, String query) async {
    // 1. Rate Limiting
    final clientIp = session.authenticated?.userIdentifier ?? 'unauthenticated';
    if (!RateLimiter.isAllowed(clientIp, limit: 10, window: const Duration(minutes: 1))) {
       session.log('Rate limit exceeded for $clientIp', level: LogLevel.warning);
       return ChatMessage(
         chatSessionId: 0, 
         ownerId: 0, 
         role: 'system', 
         content: 'Rate limit exceeded. Please wait a moment.', 
         timestamp: DateTime.now().toUtc()
       );
    }

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
      // Enforce authentication
      final userIdentifier = session.authenticated?.userIdentifier;
      if (userIdentifier == null) {
        return ChatMessage(
          chatSessionId: 0,
          ownerId: 0,
          role: 'system',
          content: 'You must be signed in to ask Recall.',
          timestamp: DateTime.now().toUtc(),
        );
      }
      final userId = int.parse(userIdentifier);

      session.log('Ask RECALL query: $query', level: LogLevel.info);

      // 0. Get or Create Session (Simplified: Single session for now)
      var sessionObj = await ChatSession.db.findFirstRow(
        session,
        where: (t) => t.ownerId.equals(userId),
        orderBy: (t) => t.updatedAt,
        orderDescending: true,
      );

      if (sessionObj == null) {
        sessionObj = ChatSession(
          ownerId: userId,
          title: 'General Chat', // Could dynamically title based on first query
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        );
        sessionObj = await ChatSession.db.insertRow(session, sessionObj);
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

      // 1b. Generate Embedding for the query
      final queryEmbedding = await GeminiService.generateEmbedding(query);
      
      // 2. Vector Search using Raw SQL
      // We search for IDs first, ordered by distance
      final embeddingString = '[${queryEmbedding.join(',')}]';
      final querySql = '''
        SELECT "id" 
        FROM "recall_interaction" 
        WHERE "ownerId" = $userId 
        ORDER BY "embedding" <=> '$embeddingString' 
        LIMIT 10
      ''';
      
      final result = await session.db.unsafeQuery(querySql);
      
      final ids = result.map((row) => row.first as int).toList();
      
      // 2b. Fetch full objects with relations
      var interactions = <Interaction>[];
      if (ids.isNotEmpty) {
        final unsorted = await Interaction.db.find(
          session,
          where: (t) => t.id.inSet(ids.toSet()),
          include: Interaction.include(contact: Contact.include()),
        );
        
        // 2c. Restore order from vector search
        final idMap = {for (var i in unsorted) i.id!: i};
        interactions = ids.map((id) => idMap[id]).whereType<Interaction>().toList();
      }

      ChatMessage assistantMessage;

      if (interactions.isEmpty) {
        assistantMessage = ChatMessage(
          chatSessionId: sessionId,
          ownerId: userId,
          role: 'assistant',
          content: "I don't have any communication history to search through yet. Once your Gmail syncs, I'll be able to answer questions about your contacts.",
          timestamp: DateTime.now().toUtc(),
          sources: [],
        );
      } else {
        // ... (Existing RAG logic)
        
        // 3. Re-ranking / Filtering (Optional, but good for relevance)
        // For now, we take top 5
        final topMatches = interactions.take(5).toList();

        // 4. Build Context
        final contexts = topMatches.map((m) {
          final contactName = m.contact?.name ?? m.contact?.email ?? 'Unknown';
          final dateStr = _formatDate(m.date);
          return '[$dateStr] $contactName: ${m.snippet}';
        }).toList();

        // 5. Generate Response
        final response = await GeminiService.generateRagResponse(
          query: query,
          retrievedContexts: contexts,
        );

        // 6. Build Sources
        final sources = topMatches.map((m) {
          final contactName = m.contact?.name ?? m.contact?.email ?? 'Unknown';
          return '$contactName (${_formatDate(m.date)})';
        }).toSet().toList();
        
        assistantMessage = ChatMessage(
          chatSessionId: sessionId,
          ownerId: userId,
          role: 'assistant',
          content: response,
          timestamp: DateTime.now().toUtc(),
          sources: sources,
        );
      }
      
      // 7. Persist Assistant Message
      await ChatMessage.db.insertRow(session, assistantMessage);
      
      // Update session timestamp
      sessionObj.updatedAt = DateTime.now().toUtc();
      await ChatSession.db.updateRow(session, sessionObj);

      return assistantMessage;

    } catch (e, stack) {
      session.log('Ask RECALL error: $e', level: LogLevel.error, stackTrace: stack);
      // Don't persist error messages to DB to avoid clutter
      return ChatMessage(
        chatSessionId: 0,
        ownerId: 1,
        role: 'assistant',
        content: "I encountered an error processing your request. Please try again.",
        timestamp: DateTime.now().toUtc(),
        sources: [],
      );
    }
  }

  /// Get chat history for the user
  Future<List<ChatMessage>> getChatHistory(Session session, {int limit = 50}) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return [];
    final userId = int.parse(userIdentifier);

    return ChatMessage.db.find(
      session,
      where: (t) => t.ownerId.equals(userId),
      orderBy: (t) => t.timestamp,
      orderDescending: false, // Oldest first for chat UI
      limit: limit,
    );
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
  Future<String> generateDraftEmail(Session session, int contactId) async {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) return 'Please sign in to generate drafts.';
    final userId = int.parse(userIdentifier);

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
}
