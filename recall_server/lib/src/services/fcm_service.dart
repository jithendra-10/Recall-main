import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  String? _accessToken;
  DateTime? _tokenExpiry;
  String? _projectId;

  Future<void> _refreshAccessToken() async {
    if (_accessToken != null && 
        _tokenExpiry != null && 
        _tokenExpiry!.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return;
    }

    try {
      final file = File('config/firebase_service_account.json');
      if (!await file.exists()) {
        throw Exception('Service account file not found');
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);
      _projectId = jsonData['project_id'];

      final accountCredentials = ServiceAccountCredentials.fromJson(jsonData);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = await clientViaServiceAccount(accountCredentials, scopes);
      _accessToken = client.credentials.accessToken.data;
      _tokenExpiry = client.credentials.accessToken.expiry;
      client.close();
      
      print('FCM: Access Token Refreshed');
    } catch (e) {
      print('FCM: Failed to refresh token: $e');
      rethrow;
    }
  }

  Future<void> sendNotification({
    required Session session,
    // required String fcmToken, // TODO: Store this in UserConfig
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // Note: Since we don't have FCM tokens stored yet in UserConfig, we can't fully target devices.
    // However, the implementation is ready. 
    // For now, this service will just log unless we add a column `fcmToken` to UserConfig.
    // For this prototype, we might skip actual sending or assume a topic?
    // Let's implement Topic messaging as it's easier for proto (subscribe all to 'generic').
    
    await _refreshAccessToken();
    
    if (_projectId == null) {
       session.log('FCM: Project ID not loaded', level: LogLevel.error);
       return;
    }

    final url = 'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
    
    // Using TOPIC 'all_users' for prototype simplicity since we don't store device tokens yet.
    // In production, we'd use 'token': fcmToken.
    final message = {
      'message': {
        'topic': 'all_users', 
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data ?? {},
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        session.log('FCM: Notification sent successfully', level: LogLevel.info);
      } else {
        session.log('FCM: Failed to send ${response.body}', level: LogLevel.error);
      }
    } catch (e) {
       session.log('FCM: Network error: $e', level: LogLevel.error);
    }
  }
}
