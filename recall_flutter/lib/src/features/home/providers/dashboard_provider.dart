import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recall_flutter/core/ip_config.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
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
          // Cast purely to be safe, Hive returns Map<dynamic, dynamic>
          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(cachedJson as Map);
          final cachedData = DashboardData.fromJson(jsonMap);
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
      
      // If we have data (from cache or previous fetch), don't wipe it out with an error screen
      if (state.data != null) {
        // Maybe show a snackbar or subtle indicator via a separate provider/state?
        // For now, just keep the old data.
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
      await client.dashboard.triggerSync();
      await fetchDashboardData();
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Future<String> processVoiceNote(String transcript) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await client.recall.processVoiceNote(transcript);
      // Refresh data as voice note might have added agenda items or contacts
      await fetchDashboardData(); 
      return result;
    } catch (e) {
      print('Voice processing error: $e');
      state = state.copyWith(isLoading: false);
      return "Failed to process voice note. Please try again.";
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
    loadSessions();
  }

  Future<void> loadSessions() async {
    try {
      final sessions = await client.recall.getChatSessions(limit: 20);
      // If we have an active session, keep it, else maybe load the most recent one?
      // For now, just load the list.
      state = state.copyWith(sessions: sessions);
      
      // If we have no active session and sessions exist, load the latest one?
      // Or let user start fresh? "Ask Recall" usually implies fresh or latest.
      // Let's load the latest one by default to be helpful.
      if (state.activeSessionId == null && sessions.isNotEmpty) {
         selectSession(sessions.first.id!);
      }
    } catch (e) {
      print('Load sessions error: $e');
    }
  }

  Future<void> selectSession(int sessionId) async {
    state = state.copyWith(isLoading: true, activeSessionId: sessionId);
    try {
      final history = await client.recall.getChatMessages(chatSessionId: sessionId, limit: 50);
      state = state.copyWith(
        messages: history,
        isLoading: false,
        activeSessionId: sessionId, // Validate
      );
    } catch (e) {
      print('Load history error: $e');
      state = state.copyWith(isLoading: false);
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
    } catch (e) {
      print('Chat error: $e');
      final errorMessage = ChatMessage(
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please try again.',
        timestamp: DateTime.now().toUtc(),
        chatSessionId: 0,
        ownerId: 0,
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      );
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
