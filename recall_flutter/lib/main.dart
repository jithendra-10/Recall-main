import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:recall_client/recall_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:recall_flutter/src/services/cache_service.dart';
import 'package:recall_flutter/src/services/offline_queue_service.dart';
import 'package:recall_flutter/src/services/notification_service.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Added
import 'package:recall_flutter/src/features/auth/views/splash_screen.dart';

import 'package:recall_flutter/src/features/home/views/dashboard_screen.dart';
import 'package:recall_flutter/src/features/auth/controllers/auth_controller.dart';
import 'package:recall_flutter/src/features/auth/views/app_bootstrap.dart';

import 'core/ip_config.dart';

/// Global client object for server communication
late final Client client;
late final SessionManager sessionManager;




// Background Handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  // Initialize Offline Services
  await CacheService().init();
  await OfflineQueueService().init(); 
  await NotificationService().init();
  await NotificationService().requestPermissions(); 
  
  // Request FCM Permission
  try {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    // Get & Print Token (Debug)
    final token = await messaging.getToken();
    print("FCM Token: $token");
    
    // Subscribe to topic for MVP (since we don't store token in DB yet)
    await messaging.subscribeToTopic('all_users');
    print("Subscribed to 'all_users' topic");
    
    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Show local notification if needed
        NotificationService().scheduleAgendaNotification(
           id: DateTime.now().millisecondsSinceEpoch ~/ 1000, 
           title: message.notification!.title ?? 'New Alert', 
           body: message.notification!.body ?? '', 
           scheduledTime: DateTime.now().add(const Duration(seconds: 1)),
        );
      }
    });

  } catch (e) {
     print("FCM Setup Failed: $e");
  }

  // Initialize client immediately without waiting for server
  final serverUrl = 'http://$serverIpAddress:8083/';

  client = Client(
    serverUrl,
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  )..connectivityMonitor = FlutterConnectivityMonitor();

  sessionManager = SessionManager(
    caller: client.modules.auth,
  );

  // Reverting to non-blocking runApp to fix Native Splash hang
  runApp(const ProviderScope(child: MyApp()));
  
  // Setup Connectivity Listener for Offline Queue
  Connectivity().onConnectivityChanged.listen((result) {
    // ... existing connectivity logic ...
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

  // Notification tests removed for production
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
      home: const AppBootstrap(),
    );
  }
}
