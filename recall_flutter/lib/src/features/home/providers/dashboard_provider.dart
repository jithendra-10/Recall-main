import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_flutter/core/ip_config.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'dart:convert';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/main.dart';
import 'package:recall_flutter/src/services/cache_service.dart';
import 'package:recall_flutter/src/services/offline_queue_service.dart';

/// Dashboard data state
class DashboardState {
  final bool isLoading;
  final String? error;
  final DashboardData? data;

  DashboardState({
    this.isLoading = true,
    this.error,
    this.data,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    DashboardData? data,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}

/// Dashboard notifier that fetches and manages dashboard data
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState()) {
    fetchDashboardData();
  }

  final _cache = CacheService();

  Future<void> fetchDashboardData() async {
    // 1. CACHE (Optimistic UI)
    if (state.data == null) {
      final cachedJson = _cache.getCachedData('dashboard_data');
      if (cachedJson != null) {
        try {
          // Hive returns Map<dynamic, dynamic> which fails for nested objects in Serverpod
          // Round-trip through JSON to ensure clean Map<String, dynamic> structure
          // This is a robust fix for "type 'identityhashmap' is not a subtype of type 'map<string, dynamic>'" errors
          final sanitizedJson = jsonDecode(jsonEncode(cachedJson));
          
          final cachedData = DashboardData.fromJson(sanitizedJson);
          state = DashboardState(isLoading: false, data: cachedData);
        } catch (e) {
          print('Cache parse error: $e');
          // If cache fails, show loading
          state = state.copyWith(isLoading: true, error: null);
        }
      } else {
        // No cache, show loading
        state = state.copyWith(isLoading: true, error: null);
      }
    } else {
      // Background refresh
      state = state.copyWith(error: null);
    }
    
    // 2. NETWORK
    try {
      // WAIT for session to initialize if starting up
      int attempts = 0;
      while (sessionManager.signedInUser == null && attempts < 5) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }

      final data = await client.dashboard.getDashboardData(
        clientReportedId: sessionManager.signedInUser?.id,
      );
      
      // 3. SYNC & SAVE
      state = DashboardState(
        isLoading: false,
        data: data,
      );
      
      // Save valid data to cache
      await _cache.cacheData('dashboard_data', data.toJson());

      // POLL: If syncing, fetch again after delay to update status
      if (data.isSyncing) {
        Future.delayed(const Duration(seconds: 3), () {
          fetchDashboardData();
        });
      }
    } catch (e) {
      print('Dashboard fetch error: $e');
      
      // If we have data (from cache or previous fetch), don't wipe it out.
      if (state.data != null) {
        state = state.copyWith(isLoading: false, error: 'Offline Mode'); 
      } else {
        state = DashboardState(
          isLoading: false,
          error: 'Failed to load dashboard data. Please check your connection.',
        );
      }
    }
  }

  final _offlineQueue = OfflineQueueService();

  Future<bool> sendEmail(String to, String subject, String body) async {
    try {
      // Use authenticated client
      final success = await client.email.sendEmail(to, subject, body);
      return success;
    } catch (e) {
      print('Send email error: $e');
      // Offline Mode: Queue action and return optimistic success
      await _offlineQueue.queueAction('draft_email', {
        'to': to,
        'subject': subject,
        'body': body,
      });
      return true;
    }
  }

  Future<void> refresh() async {
    await fetchDashboardData();
  }

  Future<void> triggerSync() async {
    try {
      // Trigger both Gmail and Calendar sync
      // Use wait to run in parallel
      await Future.wait<void>([
        client.dashboard.triggerSync(),
        client.dashboard.triggerCalendarSync(),
      ]);
      await fetchDashboardData();
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Future<String> processVoiceNote(String transcript) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await client.recall.processVoiceNote(
        transcript, 
        clientReportedId: sessionManager.signedInUser?.id,
      );
      // Refresh data as voice note might have added agenda items or contacts
      await fetchDashboardData(); 
      return result;
    } catch (e) {
      print('Voice processing error: $e');
      state = state.copyWith(isLoading: false);
      
      // Queue for offline processing
      await _offlineQueue.queueAction('voice_note', {
        'transcript': transcript,
      });
      
      return "Offline: Voice note queued for processing.";
    }
  }
}

/// Main dashboard provider
final dashboardProvider = StateNotifierProvider.autoDispose<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

/// Contacts list provider
/// Contacts state
class ContactsState {
  final bool isLoading;
  final String? error;
  final List<Contact> contacts;

  ContactsState({
    this.isLoading = true,
    this.error,
    this.contacts = const [],
  });
}

/// Contacts notifier
class ContactsNotifier extends StateNotifier<ContactsState> {
  ContactsNotifier() : super(ContactsState()) {
    fetchContacts();
  }

  final _cache = CacheService();

  Future<void> fetchContacts() async {
    // 1. CACHE
    if (state.contacts.isEmpty) {
      final cachedList = _cache.getCachedData('contacts_list');
      if (cachedList != null && cachedList is List) {
        try {
          final contacts = cachedList.map((e) {
             return Contact.fromJson(Map<String, dynamic>.from(e as Map));
          }).toList();
          state = ContactsState(isLoading: false, contacts: contacts);
        } catch (e) {
          print('Contacts cache error: $e');
        }
      }
    }

    // 2. NETWORK
    try {
       // Silent refresh if we already have data
       if (state.contacts.isNotEmpty) {
         state = ContactsState(isLoading: false, contacts: state.contacts);
       } else {
         state = ContactsState(isLoading: true, contacts: state.contacts);
       }

       final contacts = await client.dashboard.getContacts(
         clientReportedId: sessionManager.signedInUser?.id,
       );
       
       print('Frontend fetched ${contacts.length} contacts');
       state = ContactsState(isLoading: false, contacts: contacts);
       
       // 3. SAVE
       // Serverpod objects .toJson() usually works, but list needs manual mapping serialization?
       // List<Contact> -> List<Map>
       final jsonList = contacts.map((c) => c.toJson()).toList();
       await _cache.cacheData('contacts_list', jsonList);

    } catch (e) {
      print('Contacts fetch error: $e');
      if (state.contacts.isNotEmpty) {
        // Keep data, maybe set error string but don't wipe data
        // state = ContactsState(isLoading: false, contacts: state.contacts, error: 'Offline');
      } else {
        state = ContactsState(isLoading: false, error: 'Failed to load contacts', contacts: []);
      }
    }
  }
  
  Future<void> refresh() async => fetchContacts();
}

final contactsProvider = StateNotifierProvider.autoDispose<ContactsNotifier, ContactsState>((ref) {
  return ContactsNotifier();
});

/// Chat state for Ask RECALL
class ChatState {
  final List<ChatMessage> messages;
  final List<ChatSession> sessions;
  final int? activeSessionId;
  final bool isLoading;

  ChatState({
    this.messages = const [],
    this.sessions = const [],
    this.activeSessionId,
    this.isLoading = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ChatSession>? sessions,
    int? activeSessionId,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      sessions: sessions ?? this.sessions,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Chat notifier for Ask RECALL
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState()) {
    loadSessions(init: true);
  }

  final _cache = CacheService();

  Future<void> loadSessions({bool init = false}) async {
    // 1. CACHE
    if (state.sessions.isEmpty) {
      final cachedList = _cache.getCachedData('chat_sessions');
      if (cachedList != null && cachedList is List) {
        try {
          final sessions = cachedList.map((e) {
             return ChatSession.fromJson(Map<String, dynamic>.from(e as Map));
          }).toList();
          state = state.copyWith(sessions: sessions);
        } catch (e) {
           print('Chat sessions cache error: $e');
        }
      }
    }

    // 2. NETWORK
    try {
      final sessions = await client.recall.getChatSessions(limit: 20);
      state = state.copyWith(sessions: sessions);
      
      // 3. SAVE
      final jsonList = sessions.map((s) => s.toJson()).toList();
      await _cache.cacheData('chat_sessions', jsonList);

      if (init && state.activeSessionId == null && sessions.isNotEmpty) {
         selectSession(sessions.first.id!);
      }
    } catch (e) {
      print('Load sessions error: $e');
      // Keep cached data
    }
  }

  Future<void> selectSession(int sessionId) async {
    // 1. CACHE (for specific session)
    final cacheKey = 'chat_history_$sessionId';
    
    // Optimistic UI from cache
    final cachedList = _cache.getCachedData(cacheKey);
    List<ChatMessage>? cachedMessages;
    
    if (cachedList != null && cachedList is List) {
       try {
         cachedMessages = cachedList.map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e as Map))).toList();
         state = state.copyWith(
            messages: cachedMessages, 
            isLoading: true, // Still showing loading indicator for net fetch
            activeSessionId: sessionId
         );
       } catch (e) {
         print('Chat history cache error: $e');
       }
    } else {
        state = state.copyWith(isLoading: true, activeSessionId: sessionId);
    }

    // 2. NETWORK
    try {
      final history = await client.recall.getChatMessages(chatSessionId: sessionId, limit: 50);
      state = state.copyWith(
        messages: history,
        isLoading: false,
        activeSessionId: sessionId,
      );
      
      // 3. SAVE
      final jsonList = history.map((m) => m.toJson()).toList();
      await _cache.cacheData(cacheKey, jsonList);
      
    } catch (e) {
      print('Load history error: $e');
      if (cachedMessages != null) {
        state = state.copyWith(isLoading: false, messages: cachedMessages);
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void startNewChat() {
    state = ChatState(
      messages: [],
      sessions: state.sessions,
      activeSessionId: null, // Null indicates new session to be created on first message
      isLoading: false,
    );
  }

  Future<void> syncAndReload() async {
    state = state.copyWith(isLoading: true);
    try {
      // Trigger backend sync first
      await client.dashboard.triggerSync();
      // Then reload local history
      await loadSessions();
      if (state.activeSessionId != null) {
        await selectSession(state.activeSessionId!);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      print('Sync and reload error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendMessage(String query) async {
    if (query.trim().isEmpty) return;

    // Add user message immediately for UI responsiveness
    final userMessage = ChatMessage(
      role: 'user',
      content: query,
      timestamp: DateTime.now().toUtc(),
      chatSessionId: state.activeSessionId ?? 0, 
      ownerId: 0, 
    );
    
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final response = await client.recall.askRecall(query, chatSessionId: state.activeSessionId);
      
      // If this was a new session (activeSessionId was null), updates it from response
      final newSessionId = response.chatSessionId;
      
      // Refresh sessions list if it was new
      if (state.activeSessionId == null) {
         loadSessions(); // Background refresh to get the new session title
      }

      state = state.copyWith(
        messages: [...state.messages, response],
        isLoading: false,
        activeSessionId: newSessionId,
      );
      state = state.copyWith(
        messages: [...state.messages, response],
        isLoading: false,
        activeSessionId: newSessionId,
      );
      
      // Update cache for this session
      final cacheKey = 'chat_history_$newSessionId';
      final jsonList = state.messages.map((m) => m.toJson()).toList();
      await _cache.cacheData(cacheKey, jsonList);

    } catch (e) {
      print('Chat error: $e');
      
      // Queue offline message
      final offlineQueue = OfflineQueueService();
      await offlineQueue.queueAction('send_message', {
        'query': query,
        'sessionId': state.activeSessionId
      });

      // Show optimistic "Sent (Offline)" state? 
      // For now, let's keep the user message but add a system note or just leave it.
      // The user message is already in state.messages.
      
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteSession(int sessionId) async {
    // Optimistic Update
    final previousSessions = state.sessions;
    state = state.copyWith(
      sessions: state.sessions.where((s) => s.id != sessionId).toList(),
    );
    
    // If active session was deleted, clear it
    if (state.activeSessionId == sessionId) {
      startNewChat();
    }

    try {
      final success = await client.recall.deleteChatSession(sessionId);
      if (!success) {
         // Queue instead of reverting
         throw Exception('Server failed');
      }
      // Update cache
      final jsonList = state.sessions.map((s) => s.toJson()).toList();
      await _cache.cacheData('chat_sessions', jsonList);

    } catch (e) {
      print('Delete session error: $e');
      // Queue action
      final offlineQueue = OfflineQueueService();
      await offlineQueue.queueAction('delete_chat_session', {'id': sessionId});
      
      // Update cache assuming success
      final jsonList = state.sessions.map((s) => s.toJson()).toList();
      await _cache.cacheData('chat_sessions', jsonList);
    }
  }

  void clearChat() {
    startNewChat();
  }
}

/// Chat provider for Ask RECALL
final chatProvider = StateNotifierProvider.autoDispose<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

/// Draft email provider
final draftEmailProvider = FutureProvider.family<String, int>((ref, contactId) async {
  return await client.recall.generateDraftEmail(
    contactId,
    clientReportedId: sessionManager.signedInUser?.id,
  );
});
