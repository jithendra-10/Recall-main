import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:recall_client/recall_client.dart';
import 'package:recall_flutter/main.dart'; // for client & sessionManager
import 'package:recall_flutter/src/services/cache_service.dart';

class AgendaState {
  final bool isLoading;
  final String? error;
  final List<AgendaItem> items;
  final DateTime date;

  AgendaState({
    this.isLoading = true,
    this.error,
    this.items = const [],
    required this.date,
  });

  AgendaState copyWith({
    bool? isLoading,
    String? error,
    List<AgendaItem>? items,
    DateTime? date,
  }) {
    return AgendaState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
      date: date ?? this.date,
    );
  }
}

class AgendaNotifier extends StateNotifier<AgendaState> {
  final DateTime date;
  
  AgendaNotifier(this.date) : super(AgendaState(date: date)) {
    fetchAgenda();
  }

  final _cache = CacheService();
  String get _cacheKey => 'agenda_${DateFormat('yyyy-MM-dd').format(date)}';

  Future<void> fetchAgenda() async {
    // 1. CACHE (Optimistic)
    if (state.items.isEmpty) {
      final cachedList = _cache.getCachedData(_cacheKey);
      if (cachedList != null && cachedList is List) {
        try {
          final items = cachedList.map((e) {
            // Need to handle Serialization carefully
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
      // Start of day
      final start = DateTime(date.year, date.month, date.day).toUtc();
      // End of day
      final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

      // Silent loading if we have data
      if (state.items.isEmpty) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final items = await client.dashboard.getAgendaItems(start, end);

      state = state.copyWith(isLoading: false, items: items, error: null);

      // 3. SAVE TO CACHE
      final jsonList = items.map((e) => e.toJson()).toList();
      await _cache.cacheData(_cacheKey, jsonList);

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
  
  Future<void> refresh() async => fetchAgenda();
}

// Ensure unique provider per date
final agendaProvider = StateNotifierProvider.family.autoDispose<AgendaNotifier, AgendaState, DateTime>((ref, date) {
  return AgendaNotifier(date);
});
