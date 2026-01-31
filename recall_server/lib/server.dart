import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/module.dart' hide Protocol, Endpoints, GoogleClientSecret;
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';
import 'src/future_calls/gmail_sync_future_call.dart';
import 'src/future_calls/calendar_sync_future_call.dart';
import 'src/future_calls/morning_briefing_future_call.dart';
import 'package:dotenv/dotenv.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Load environment variables
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Initialize authentication services for the server.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      ServerSideSessionsConfig(
        sessionKeyHashPepper: 'ThisIsARandomSessionKeyPepper123!',
        // Optional: validationCodeHashPepper: '...',
      ),
    ],
    identityProviderBuilders: [
      // Email identity provider
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: _sendRegistrationCode,
        sendPasswordResetVerificationCode: _sendPasswordResetCode,
      ),
      // Google identity provider
      GoogleIdpConfig(
        clientSecret: GoogleClientSecret.fromJson({
          'web': {
            'client_id': env['GOOGLE_CLIENT_ID']!,
            'client_secret': env['GOOGLE_CLIENT_SECRET']!,
            'redirect_uris': [
              'http://localhost:8082/googlesignin',
              'http://192.168.88.194.nip.io:8082/googlesignin',
            ],
          }
        }),
      ),
    ],
  );

  // Setup web routes
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  // Register Future Calls
  pod.registerFutureCall(GmailSyncFutureCall(), 'gmail_sync');
  pod.registerFutureCall(CalendarSyncFutureCall(), 'calendarSync');
  pod.registerFutureCall(MorningBriefingFutureCall(), 'morning_briefing');

  // App config route
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  // Flutter web app
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    pod.webServer.addRoute(
      FlutterRoute(Directory(Uri(path: 'web/app').toFilePath())),
      '/app',
    );
  } else {
    pod.webServer.addRoute(
      StaticRoute.file(File(Uri(path: 'web/pages/build_flutter_app.html').toFilePath())),
      '/app/**',
    );
  }

  // Start the server.
  await pod.start();

  // Schedule background sync (Run every 15 minutes)
  // Use a delay to ensure server is fully up
  Future.delayed(const Duration(seconds: 10), () async {
    try {
      final session = await pod.createSession(enableLogging: true);
      
      // Cleanup: Reset any stuck 'isSyncing' flags from previous crashes
      try {
        await session.db.unsafeQuery(
          'UPDATE recall_user_config SET "isSyncing" = false WHERE "isSyncing" = true'
        );
        session.log('Startup: Reset stuck sync flags', level: LogLevel.info);
      } catch (e) {
        session.log('Startup Cleanup Error: $e', level: LogLevel.warning);
      }

      // Schedule the first call in 1 minute
      // Note: In production, rely on strict cron or widespread triggers.
      // This is a simplified recurrence for the prototype.
      // Serverpod's FutureCall scheduling is typically done relative to "now".
      await session.serverpod.futureCallWithDelay(
        'gmail_sync', 
        null, 
        const Duration(minutes: 1),
      );
      
      // Schedule Morning Briefing (2 mins from now for demo)
      await session.serverpod.futureCallWithDelay(
        'morning_briefing', 
        null, 
        const Duration(minutes: 2),
      );
      
      session.log('Background Sync Scheduled', level: LogLevel.info);
      
      // RUN HEALING ON STARTUP
      // This fixes any "Unknown" contacts from previous versions
      await _runDataHealing(session);
      
      await session.close();
    } catch (e) {
      print('Failed to schedule initial sync: $e');
    }
  });
}

Future<void> _runDataHealing(Session session) async {
  session.log('🩺 Running Startup Data Healing (Enhanced)...', level: LogLevel.info);
  try {
    final interactions = await Interaction.db.find(
      session,
      where: (t) => t.linkedContactId.equals(null),
    );
    
    if (interactions.isEmpty) return;

    final contacts = await Contact.db.find(session);
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    
    int linkedCount = 0;

    for (var interaction in interactions) {
       final text = (interaction.snippet + " " + (interaction.subject ?? "") + " " + (interaction.body ?? "")).toLowerCase();
       bool matchFound = false;

       // 1. Try Email Regex Match
       final emailMatches = emailRegex.allMatches(text);
       for (final match in emailMatches) {
          final email = match.group(0)?.toLowerCase();
          if (email != null) {
             final contact = contacts.cast<Contact?>().firstWhere(
                (c) => c?.email?.toLowerCase() == email,
                orElse: () => null,
             );
             
             if (contact != null) {
                interaction.linkedContactId = contact.id;
                await Interaction.db.updateRow(session, interaction);
                linkedCount++;
                matchFound = true;
                break;
             }
          }
       }
       if (matchFound) continue;

       // 2. Try Name Match (Fallback)
       for (var contact in contacts) {
          final name = contact.name?.toLowerCase();
          if (name != null && name.length > 3 && text.contains(name)) {
             interaction.linkedContactId = contact.id;
             await Interaction.db.updateRow(session, interaction);
             linkedCount++;
             break; 
          }
       }
    }
    if (linkedCount > 0) {
      session.log('✅ Startup Healing: Linked $linkedCount interactions.', level: LogLevel.info);
    }
    
    // Agenda Healing (Simplified)
    final agendaItems = await AgendaItem.db.find(
      session,
      where: (t) => t.linkedContactId.equals(null),
    );
    
    for (var item in agendaItems) {
       final text = (item.title + " " + (item.description ?? "")).toLowerCase();
       for (var contact in contacts) {
          final name = contact.name?.toLowerCase();
          if (name != null && name.length > 3 && text.contains(name)) {
             item.linkedContactId = contact.id;
             await AgendaItem.db.updateRow(session, item);
             break;
          }
       }
    }
    
  } catch (e) {
    session.log('Startup Healing Error: $e', level: LogLevel.error);
  }
}

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  session.log('[EmailIdp] Registration code ($email): $verificationCode');
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  session.log('[EmailIdp] Password reset code ($email): $verificationCode');
}
