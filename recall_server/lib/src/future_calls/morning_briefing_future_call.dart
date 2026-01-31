import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/fcm_service.dart';

class MorningBriefingFutureCall extends FutureCall {
  @override
  Future<void> invoke(Session session, dynamic object) async {
    session.log('🌅 Starting Morning Briefing...', level: LogLevel.info);

    try {
      // 1. Get All Users (In prod, we'd loop. MVP: Just target broadly or user 1)
      final users = await UserConfig.db.find(session);
      
      for (var user in users) {
          await _sendBriefingForUser(session, user);
      }
      
      // 2. Reschedule for next day (approx 24h later)
      // For a real production app, we'd calculate time until next 8:00 AM.
      // Here we just reschedule for 24 hours.
      session.log('Scheduling next Morning Briefing in 24 hours', level: LogLevel.info);
      session.serverpod.futureCallWithDelay(
        'morning_briefing', 
        null, 
        const Duration(hours: 24),
      );

    } catch (e) {
      session.log('Failed to run Morning Briefing: $e', level: LogLevel.error);
    }
  }

  Future<void> _sendBriefingForUser(Session session, UserConfig user) async {
      // A. Fetch Today's Agenda
      final now = DateTime.now().toUtc();
      final todayStart = DateTime(now.year, now.month, now.day).toUtc();
      final todayEnd = todayStart.add(const Duration(days: 1));

      final agendaCount = await AgendaItem.db.count(
         session,
         where: (t) => t.ownerId.equals(user.userInfoId) & 
                       t.startTime.between(todayStart, todayEnd),
      );

      // B. Fetch Drifting Contacts
      final driftingCount = await Contact.db.count(
         session,
         where: (t) => t.ownerId.equals(user.userInfoId) & 
                       (t.healthScore < 50.0),
      );

      if (agendaCount == 0 && driftingCount == 0) return;

      // C. Construct Message
      final message = "You have $agendaCount meetings today.$driftingCount relationships need attention.";
      
      // D. Send Push
      await FCMService().sendNotification(
         session: session, 
         title: 'Morning Briefing ☕', 
         body: message,
         data: {
            'type': 'briefing',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK', 
         }
      );
      
      session.log('Sent Morning Briefing to user ${user.userInfoId}', level: LogLevel.info);
  }
}
