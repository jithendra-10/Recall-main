import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for connectivity
class ConnectivityState {
  final bool isConnected;
  final bool isOfflineMode; // For manual toggle if we add it later

  ConnectivityState({
    this.isConnected = true,
    this.isOfflineMode = false,
  });
}

/// Notifier to track connectivity
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier() : super(ConnectivityState()) {
    _init();
  }

  void _init() {
    // Check initial
    Connectivity().checkConnectivity().then(_updateStatus);

    // Listen
    Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(dynamic result) {
    // Handle both List<ConnectivityResult> (v6) and single (v5)
    bool hasNet = false;
    if (result is List<ConnectivityResult>) {
      hasNet = result.any((r) => r != ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      hasNet = result != ConnectivityResult.none;
    } else if (result is List) {
      // Fallback for generic list
      hasNet = (result).any((r) => r != ConnectivityResult.none);
    }

    state = ConnectivityState(isConnected: hasNet);
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});
