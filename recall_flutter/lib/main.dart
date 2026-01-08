import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:recall_client/recall_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:recall_flutter/src/services/cache_service.dart';
import 'package:recall_flutter/src/services/offline_queue_service.dart';

import 'package:recall_flutter/src/features/auth/views/splash_screen.dart';

import 'core/ip_config.dart';

/// Global client object for server communication
late final Client client;
late final SessionManager sessionManager;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Offline Services
  await CacheService().init();
  await OfflineQueueService().init(); 

  // Initialize client immediately without waiting for server
  final serverUrl = 'http://$serverIpAddress:8083/';

  client = Client(
    serverUrl,
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  )..connectivityMonitor = FlutterConnectivityMonitor();

  sessionManager = SessionManager(
    caller: client.modules.auth,
  );

  // Start app immediately - don't wait for session initialization
  runApp(const ProviderScope(child: MyApp()));

  // Setup Connectivity Listener for Offline Queue
  Connectivity().onConnectivityChanged.listen((result) {
    // Check if result is NOT none (basic check, can be improved)
    // Note: connectivity_plus 6.0 returns List<ConnectivityResult>, 5.0 returns single. 
    // Assuming 5.0 behavior based on ^5.0.2 constraint, but handling safe.
    bool isConnected = false;
    if (result is List) {
       isConnected = (result as List).any((r) => r != ConnectivityResult.none);
    } else {
       isConnected = result != ConnectivityResult.none;
    }

    if (isConnected) {
      print("Recall: Network restored. Processing offline queue...");
      OfflineQueueService().processQueue(client);
    }
  });

  // Initialize session in background (non-blocking)
  _initializeSessionInBackground();
}

/// Initialize session manager in background to avoid blocking app startup
Future<void> _initializeSessionInBackground() async {
  try {
    // Use Future.any to race between initialization and timeout
    await Future.any([
      sessionManager.initialize(),
      Future.delayed(const Duration(seconds: 5)),
    ]);
    print('Recall: Session initialization completed');
  } catch (e) {
    print('Recall: Session initialization failed: $e');
    // App continues to work without session - user can sign in manually
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recall',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1D23),
      ),
      home: const SplashScreen(),
    );
  }
}
