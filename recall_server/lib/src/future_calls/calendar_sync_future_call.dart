import 'dart:io';
import 'dart:convert';
import 'package:dotenv/dotenv.dart';
import 'package:serverpod/serverpod.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';
import '../services/gemini_service.dart';
import '../utils/encryption_helper.dart';

class CalendarSyncFutureCall extends FutureCall {
  // Load credentials from config file - reusing logic from GmailSync
  static late String _clientId;
  static late String _clientSecret;
  static bool _credentialsLoaded = false;

  static Future<void> _loadCredentials() async {
    if (_credentialsLoaded) return;
    
    // Try environment variables first
    final env = DotEnv(includePlatformEnvironment: true);
    if (env.isDefined('GOOGLE_CLIENT_ID') && env.isDefined('GOOGLE_CLIENT_SECRET')) {
      _clientId = env['GOOGLE_CLIENT_ID']!;
      _clientSecret = env['GOOGLE_CLIENT_SECRET']!;
      _credentialsLoaded = true;
      return;
    }

    // Fallback to JSON file
    try {
      final configFile = File('config/google_client_secret.json');
      if (await configFile.exists()) {
        final configJson = jsonDecode(await configFile.readAsString());
        final data = configJson['installed'] ?? configJson['web'];
        _clientId = data['client_id'];
        _clientSecret = data['client_secret'];
        _credentialsLoaded = true;
      } else {
        throw Exception('Credentials not found in .env or config/google_client_secret.json');
      }
    } catch (e) {
      throw Exception('Failed to load Google credentials: $e');
    }
  }

  @override
  Future<void> invoke(Session session, dynamic object) async {
    session.log('Starting Calendar Sync...', level: LogLevel.info);

    await _loadCredentials();

    // Check if we are syncing a specific user
    int? targetedUserId;
    if (object is UserConfig) {
      targetedUserId = object.userInfoId;
      session.log('Targeting specific user via UserConfig: $targetedUserId', level: LogLevel.info);
    } else if (object is int) {
      targetedUserId = object;
    }

    // Fetch users with a Google Refresh Token
    final users = await UserConfig.db.find(
      session,
      where: (t) => t.googleRefreshToken.notEquals(null) & 
                   (targetedUserId != null ? t.userInfoId.equals(targetedUserId) : Constant.bool(true)),
    );

    session.log('Found ${users.length} users with Google tokens', level: LogLevel.info);

    for (var userConfig in users) {
      try {
        await _syncUser(session, userConfig);
      } catch (e, stack) {
        session.log(
          'Failed to sync calendar for user ${userConfig.userInfoId}: $e',
          level: LogLevel.error,
          exception: e,
          stackTrace: stack,
        );
      }
    }
  }

  Future<void> _syncUser(Session session, UserConfig userConfig) async {
    final encryptedToken = userConfig.googleRefreshToken!;
    final refreshToken = EncryptionHelper.decrypt(encryptedToken);

    if (refreshToken.isEmpty) {
        session.log('Failed to decrypt token for user ${userConfig.userInfoId}', level: LogLevel.error);
        return;
    }
    
    session.log('Syncing calendar for user ${userConfig.userInfoId}...', level: LogLevel.info);

    final credentials = AccessCredentials(
      AccessToken('Bearer', '', DateTime.now().toUtc().subtract(const Duration(hours: 1))),
      refreshToken,
      ['https://www.googleapis.com/auth/calendar.readonly'],
    );

    final authClient = autoRefreshingClient(
      ClientId(_clientId, _clientSecret),
      credentials,
      http.Client(),
    );

    try {
      final calendarApi = calendar.CalendarApi(authClient);
      
      final now = DateTime.now().toUtc();
      // Sync from yesterday to 30 days ahead
      final timeMin = now.subtract(const Duration(days: 1));
      final timeMax = now.add(const Duration(days: 30));

      final eventsStream = await calendarApi.events.list(
        'primary', 
        timeMin: timeMin,
        timeMax: timeMax,
        singleEvents: true,
        orderBy: 'startTime',
      );
      
      final events = eventsStream.items;

      if (events != null && events.isNotEmpty) {
        session.log('Found ${events.length} calendar events', level: LogLevel.info);
        
        for (var event in events) {
          try {
             await _processEvent(session, userConfig, event);
          } catch (e) {
             session.log('Error processing event ${event.id}: $e', level: LogLevel.warning);
          }
        }
      } else {
        session.log('No calendar events found.', level: LogLevel.info);
      }
      
      session.log('Calendar Sync completed for user ${userConfig.userInfoId}', level: LogLevel.info);

    } catch (e) {
      if (e.toString().contains('start time must be before end time')) {
         // Should not happen with fixed relative dates, but good to catch
      } else if (e.toString().contains('Insufficient Permission') || e.toString().contains('403')) {
         session.log('Calendar permission missing for user ${userConfig.userInfoId}. Skipped.', level: LogLevel.warning);
         // User might need to re-login to grant scope
      } else {
         rethrow;
      }
    } finally {
      authClient.close();
    }
  }

  Future<void> _processEvent(Session session, UserConfig userConfig, calendar.Event event) async {
    if (event.status == 'cancelled') return;
    
    final title = event.summary ?? 'Busy';
    final description = event.description;
    
    // Parse times
    DateTime? startTime;
    DateTime? endTime;
    
    if (event.start?.dateTime != null) {
      startTime = event.start!.dateTime!; // Already DateTime
    } else if (event.start?.date != null) {
      // All-day event
      startTime = event.start!.date!;
    }
    
    if (event.end?.dateTime != null) {
      endTime = event.end!.dateTime!;
    } else if (event.end?.date != null) {
      endTime = event.end!.date!;
    }

    if (startTime == null) return;
    endTime ??= startTime.add(const Duration(hours: 1)); // Default duration if missing
    
    // Check if duplicate (by title and exact time)
    // Ideally we should store the Google Event ID (iCalUID) but schema modification is expensive now.
    // For now, simple de-dupe logic.
    final existing = await AgendaItem.db.findFirstRow(
      session,
      where: (t) => t.ownerId.equals(userConfig.userInfoId) & 
                    t.title.equals(title) & 
                    t.startTime.equals(startTime),
    );
    
    if (existing != null) {
      // Could update if needed?
      return; 
    }
    
    final agendaItem = AgendaItem(
      ownerId: userConfig.userInfoId,
      linkedContactId: null, // No specific contact link usually
      interactionId: 0,
      title: title,
      description: description ?? 'Imported from Google Calendar',
      startTime: startTime,
      endTime: endTime,
      priority: 'normal',
      status: 'pending',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    
    // Check for "Google Calendar" prefix in title? No, user wants real feel.
    // But we might want to differentiate visually in UI later. For now, just insert.
    await AgendaItem.db.insertRow(session, agendaItem);
    session.log('Imported event: $title at $startTime', level: LogLevel.debug);
  }
}
