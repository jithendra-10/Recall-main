import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize Timezone Database
    tz.initializeTimeZones();
    
    // Get Device Timezone
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      print("NotificationService: Device Timezone -> $currentTimeZone");
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      print("NotificationService: Failed to get local timezone: $e");
      // Fallback to UTC or a default if needed, or let it crash to debug
      tz.setLocalLocation(tz.getLocation('UTC')); 
    }

    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        print("Notification tapped: ${details.payload}");
      },
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> scheduleAgendaNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Only schedule if time is in the future
    if (scheduledTime.isBefore(DateTime.now())) return;

    print("Scheduling Notification [$id] for: $scheduledTime (Local)");
    
    // Verify Timezone
    try {
      final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
      print("NotificationService: Converting to TZDateTime -> $tzTime");
      
      if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) {
         print("NotificationService: WARNING - Scheduled time $tzTime is in the PAST!");
      }
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'recall_alerts_v2', // PROVEN WORKING CHANNEL
            'Recall Alerts',
            channelDescription: 'High priority notifications for agenda items',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            visibility: NotificationVisibility.public,
            fullScreenIntent: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("NotificationService: Successfully scheduled ID $id");
    } catch (e) {
      print("NotificationService: CRITICAL ERROR - Failed to schedule: $e");
    }
  }
  
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
