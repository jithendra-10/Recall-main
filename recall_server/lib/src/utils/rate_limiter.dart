import 'dart:collection';


/// A simple in-memory rate limiter using a sliding window algorithm.
/// Note: For production with multiple server instances, use Redis.
class RateLimiter {
  // Map of "IP/User ID" -> List of timestamps
  static final Map<String, Queue<DateTime>> _requests = {};
  
  // Cleanup interval
  static DateTime _lastCleanup = DateTime.now();

  /// Check if a request is allowed.
  /// [key] is usually IP or User ID.
  /// [limit] is max requests.
  /// [window] is the time window (e.g., 1 minute).
  static bool isAllowed(String key, {int limit = 60, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    
    // Periodic cleanup (every 5 mins)
    if (now.difference(_lastCleanup).inMinutes > 5) {
      _cleanup(window);
    }

    if (!_requests.containsKey(key)) {
      _requests[key] = Queue();
    }

    final timestamps = _requests[key]!;

    // Remove old timestamps outside the window
    while (timestamps.isNotEmpty && now.difference(timestamps.first) > window) {
      timestamps.removeFirst();
    }

    if (timestamps.length >= limit) {
      return false; // Rate limit exceeded
    }

    timestamps.add(now);
    return true;
  }

  static void _cleanup(Duration window) {
    final now = DateTime.now();
    _requests.removeWhere((key, timestamps) {
      // Remove valid timestamps first
      while (timestamps.isNotEmpty && now.difference(timestamps.first) > window) {
        timestamps.removeFirst();
      }
      return timestamps.isEmpty;
    });
    _lastCleanup = now;
  }
}
