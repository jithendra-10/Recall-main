import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/main.dart'; // for client & sessionManager
import 'package:recall_flutter/src/services/cache_service.dart';
import 'package:recall_flutter/src/services/cache_service.dart';
import 'package:recall_flutter/src/services/offline_queue_service.dart';
import 'package:recall_flutter/src/services/notification_service.dart';

enum AgendaView { all, present, future, past }

class AgendaState {
  final bool isLoading;
  final String? error;
  final List<AgendaItem> items;
  final AgendaView view;

  AgendaState({
    this.isLoading = true,
    this.error,
    this.items = const [],
    required this.view,
  });

  AgendaState copyWith({
    bool? isLoading,
    String? error,
    List<AgendaItem>? items,
    AgendaView? view,
  }) {
    return AgendaState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
      view: view ?? this.view,
    );
  }
}

class AgendaNotifier extends StateNotifier<AgendaState> {
  final AgendaView view;
  
  AgendaNotifier(this.view) : super(AgendaState(view: view)) {
    fetchAgenda();
  }

  final _cache = CacheService();
  String get _cacheKey => 'agenda_${view.name}';

  Future<void> fetchAgenda() async {
    // 1. CACHE (Optimistic)
    if (state.items.isEmpty) {
      final cachedList = _cache.getCachedData(_cacheKey);
      if (cachedList != null && cachedList is List) {
        try {
          final items = cachedList.map((e) {
            return AgendaItem.fromJson(Map<String, dynamic>.from(e as Map));
          }).toList();
          
          state = state.copyWith(isLoading: false, items: items, error: null);
        } catch (e) {
          print('Agenda cache parse error: $e');
        }
      }
    }

    // 2. NETWORK
    try {
      // Use Local time to determine "Today" boundaries correctly for the user
      final now = DateTime.now();
      final todayStartLocal = DateTime(now.year, now.month, now.day);
      final todayEndLocal = todayStartLocal.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
      
      final todayStart = todayStartLocal.toUtc();
      final todayEnd = todayEndLocal.toUtc();

      DateTime start;
      DateTime end;

      switch (view) {
        case AgendaView.all:
          start = todayStart.subtract(const Duration(days: 30));
          end = todayStart.add(const Duration(days: 90));
          break;
        case AgendaView.present:
          start = todayStart;
          end = todayEnd;
          break;
        case AgendaView.future:
          start = todayEnd.add(const Duration(milliseconds: 1)); // Tomorrow start
          end = todayStart.add(const Duration(days: 90)); // Next 90 days
          break;
        case AgendaView.past:
          start = todayStart.subtract(const Duration(days: 30)); // Last 30 days
          end = todayStart.subtract(const Duration(milliseconds: 1)); // Yesterday end
          break;
      }

      // Silent loading if we have data
      if (state.items.isEmpty) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final items = await client.dashboard.getAgendaItems(start, end);

      state = state.copyWith(isLoading: false, items: items, error: null);

      // 3. SAVE TO CACHE
      final jsonList = items.map((e) => e.toJson()).toList();
      await _cache.cacheData(_cacheKey, jsonList);
      
      // 4. SCHEDULE NOTIFICATIONS (Only for 'future' or 'all' view to avoid redundant calls)
      // Ideally we should have a centralized place for this, but doing it on fetch keeps it in sync.
      // We only clear/reschedule if we fetched successfully from network to avoid clearing valid alerts on error.
      if (view == AgendaView.future || view == AgendaView.all || view == AgendaView.present) {
          // Note: This matches the basic strategy. 
          // For a robust system, we might want to be more selective about what we cancel.
          // But "Cancel All & Reschedule" ensures we delete alerts for deleted items.
          await NotificationService().cancelAll();
          
          for (final item in items) {
             // Only schedule if it has a valid start time in the future
             if (item.startTime.isAfter(DateTime.now())) {
                await NotificationService().scheduleAgendaNotification(
                   id: item.id ?? item.startTime.millisecondsSinceEpoch ~/ 1000, 
                   title: 'Upcoming: ${item.title}', 
                   body: item.description ?? 'You have a scheduled item.', 
                   scheduledTime: item.startTime,
                );
             }
          }
      }

    } catch (e) {
      print('Agenda fetch error: $e');
      if (state.items.isNotEmpty) {
        // Keep data, maybe show offline indicator via other means
      } else {
        state = state.copyWith(
          isLoading: false, 
          error: 'Could not load agenda. Please check your connection.',
          items: []
        );
      }
    }
  }
  
  Future<void> deleteItem(int id) async {
    // Optimistic Update
    final previousItems = state.items;
    state = state.copyWith(items: state.items.where((i) => i.id != id).toList());

    try {
      final success = await client.dashboard.deleteAgendaItem(id);
      if (!success) {
        // Revert on failure
        state = state.copyWith(items: previousItems, error: 'Failed to delete item');
      } else {
        // Update cache
        final jsonList = state.items.map((e) => e.toJson()).toList();
        await _cache.cacheData(_cacheKey, jsonList);
      }
    } catch (e) {
      print('Delete error: $e');
      // Queue for offline processing instead of reverting
      // We assume the optimistic update is correct
      final offlineQueue = OfflineQueueService();
      await offlineQueue.queueAction('delete_agenda_item', {'id': id});
      
      // Update cache with the item removed
      final jsonList = state.items.map((e) => e.toJson()).toList();
      await _cache.cacheData(_cacheKey, jsonList);
    }
  }
  
  Future<void> addManualItem(AgendaItem item) async {
    // Optimistic Update: Add to list immediately (requires generating temp ID if needed, or just append)
    // Actually, simple way: fetch again after add.
    // Or optimistic:
    final optimisticItem = item.copyWith(id: -1); // Temp ID
    final previousItems = state.items;
    
    // Insert sorted
    final newItems = [...state.items, optimisticItem];
    newItems.sort((a, b) => a.startTime.compareTo(b.startTime));
    state = state.copyWith(items: newItems);

    try {
      final added = await client.dashboard.addAgendaItem(item);
      if (added != null) {
        // Replace temp item with real one
        final updatedItems = state.items.map((i) => i.id == -1 ? added : i).toList();
        state = state.copyWith(items: updatedItems);
        
        // Cache
        final jsonList = state.items.map((e) => e.toJson()).toList();
        await _cache.cacheData(_cacheKey, jsonList);
        
        // Notifications
        final now = DateTime.now();
        print("Agenda: Item Added. Start: ${added.startTime} (IsUtc: ${added.startTime.isUtc}) vs Now: $now (IsUtc: ${now.isUtc})");
        
        if (added.startTime.isAfter(now)) {
            print("Agenda: Time is in future. Scheduling ID: ${added.id}");
            await NotificationService().scheduleAgendaNotification(
               id: added.id!, 
               title: 'Upcoming: ${added.title}', 
               body: added.description ?? '', 
               scheduledTime: added.startTime,
            );
        } else {
            print("Agenda: Time is in PAST. Skipping notification.");
        }
      } else {
        // Failed
        state = state.copyWith(items: previousItems, error: 'Failed to add item');
      }
    } catch (e) {
      print('Add manual item error: $e');
      // Queue offline
       final offlineQueue = OfflineQueueService();
       // Serialize manual add? Protocol doesn't have SerializableEntity for 'manual_add' specifically
       // We can store the Item json
       await offlineQueue.queueAction('add_agenda_item', item.toJson());
       
       // Keep optimistic item but maybe mark as pending? 
       // For now, keep it.
    }
  }

  Future<void> refresh() async => fetchAgenda();
}

// Ensure unique provider per view
final agendaProvider = StateNotifierProvider.family.autoDispose<AgendaNotifier, AgendaState, AgendaView>((ref, view) {
  return AgendaNotifier(view);
});
