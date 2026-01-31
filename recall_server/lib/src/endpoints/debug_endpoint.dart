import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Debug endpoint for testing - to be removed in production
class DebugEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  /// Seed test data for dashboard verification
  Future<String> seedTestData(Session session) async {
    session.log('Seeding test data...', level: LogLevel.info);

    try {
      // Create a test user config (user ID 1)
      const testUserId = 1;

      // Check if already has data
      final existingContacts = await Contact.db.find(
        session,
        where: (t) => t.ownerId.equals(testUserId),
      );
      
      if (existingContacts.isNotEmpty) {
        return 'Test data already exists (${existingContacts.length} contacts)';
      }

      // Create UserConfig
      var userConfig = await UserConfig.db.findFirstRow(
        session,
        where: (t) => t.userInfoId.equals(testUserId),
      );
      
      if (userConfig == null) {
        userConfig = UserConfig(
          userInfoId: testUserId,
          lastSyncTime: DateTime.now().toUtc(),
          dailyBriefingTime: 8,
          isPro: false,
          driftingAlertsEnabled: true,
          weeklyDigestEnabled: true,
          newMemoryAlertsEnabled: true,
        );
        await UserConfig.db.insertRow(session, userConfig);
      }

      // Create realistic contacts
      final contacts = [
        Contact(
          ownerId: testUserId,
          email: 'rahul.sharma@gmail.com',
          name: 'Rahul Sharma',
          healthScore: 42.0,
          tier: 1,
          lastContacted: DateTime.now().subtract(const Duration(days: 28)),
        ),
        Contact(
          ownerId: testUserId,
          email: 'priya.patel@gmail.com',
          name: 'Priya Patel',
          healthScore: 85.0,
          tier: 1,
          lastContacted: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Contact(
          ownerId: testUserId,
          email: 'arjun.mehta@gmail.com',
          name: 'Arjun Mehta',
          healthScore: 72.0,
          tier: 2,
          lastContacted: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        Contact(
          ownerId: testUserId,
          email: 'sneha.gupta@gmail.com',
          name: 'Sneha Gupta',
          healthScore: 58.0,
          tier: 2,
          lastContacted: DateTime.now().subtract(const Duration(days: 12)),
        ),
        Contact(
          ownerId: testUserId,
          email: 'vikram.singh@gmail.com',
          name: 'Vikram Singh',
          healthScore: 35.0,
          tier: 1,
          lastContacted: DateTime.now().subtract(const Duration(days: 21)),
        ),
      ];

      final insertedContacts = <Contact>[];
      for (var contact in contacts) {
        final inserted = await Contact.db.insertRow(session, contact);
        insertedContacts.add(inserted);
      }

      // Create realistic interactions
      final interactions = [
        Interaction(
          ownerId: testUserId,
          linkedContactId: insertedContacts[1].id!, // Priya
          date: DateTime.now().subtract(const Duration(hours: 2)),
          snippet: 'Shared notes from the product sync meeting - discussed Q1 roadmap priorities',
          type: 'email_in',
          embedding: Vector(List.filled(768, 0.0)),
        ),
        Interaction(
          ownerId: testUserId,
          linkedContactId: insertedContacts[2].id!, // Arjun
          date: DateTime.now().subtract(const Duration(hours: 5)),
          snippet: 'You followed up on the Mumbai trip plans for next month',
          type: 'email_out',
          embedding: Vector(List.filled(768, 0.0)),
        ),
        Interaction(
          ownerId: testUserId,
          linkedContactId: insertedContacts[3].id!, // Sneha
          date: DateTime.now().subtract(const Duration(days: 1)),
          snippet: 'Quarterly review discussion - performance metrics and team goals',
          type: 'meeting',
          embedding: Vector(List.filled(768, 0.0)),
        ),
        Interaction(
          ownerId: testUserId,
          linkedContactId: insertedContacts[0].id!, // Rahul
          date: DateTime.now().subtract(const Duration(days: 28)),
          snippet: 'Internship referral at Google - his team is hiring for ML roles, promised to forward your resume',
          type: 'email_in',
          embedding: Vector(List.filled(768, 0.0)),
        ),
        Interaction(
          ownerId: testUserId,
          linkedContactId: insertedContacts[4].id!, // Vikram
          date: DateTime.now().subtract(const Duration(days: 21)),
          snippet: 'Discussed startup investment opportunity - follow up needed on term sheet',
          type: 'email_in',
          embedding: Vector(List.filled(768, 0.0)),
        ),
      ];

      for (var interaction in interactions) {
        await Interaction.db.insertRow(session, interaction);
      }

      session.log('Test data seeded successfully', level: LogLevel.info);
      return 'Seeded ${contacts.length} contacts and ${interactions.length} interactions';
      
    } catch (e, stack) {
      session.log('Error seeding data: $e', level: LogLevel.error, stackTrace: stack);
      return 'Error: $e';
    }
  }

  /// Clear all test data
  Future<String> clearTestData(Session session) async {
    const testUserId = 1;
    
    try {
      // Delete interactions first (foreign key)
      await Interaction.db.deleteWhere(
        session,
        where: (t) => t.ownerId.equals(testUserId),
      );
      
      // Delete contacts
      await Contact.db.deleteWhere(
        session,
        where: (t) => t.ownerId.equals(testUserId),
      );
      
      // Delete user config
      await UserConfig.db.deleteWhere(
        session,
        where: (t) => t.userInfoId.equals(testUserId),
      );
      
      return 'Test data cleared';
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Heal orphaned data by linking to contacts
  Future<String> healData(Session session) async {
    session.log('🔎 Starting Data Healing Process...', level: LogLevel.info);
    
    try {
      // 1. Fetch orphaned interactions
      final interactions = await Interaction.db.find(
        session,
        where: (t) => t.linkedContactId.equals(null),
      );
      
      // 2. Fetch all contacts
      final contacts = await Contact.db.find(session);
      
      int linkedCount = 0;

      for (var interaction in interactions) {
         final text = (interaction.snippet + " " + (interaction.subject ?? "")).toLowerCase();
         
         for (var contact in contacts) {
            final name = contact.name?.toLowerCase();
            if (name != null && name.length > 3 && text.contains(name)) {
               // Found a match!
               interaction.linkedContactId = contact.id;
               await Interaction.db.updateRow(session, interaction);
               session.log('✅ Linked interaction to Contact: ${contact.name}');
               linkedCount++;
               break; 
            }
         }
      }
      
      // Also fix Agenda Items if any
      final agendaItems = await AgendaItem.db.find(
        session,
        where: (t) => t.linkedContactId.equals(null),
      );
      
      int agendaCount = 0;
      
      for (var item in agendaItems) {
         final text = (item.title + " " + (item.description ?? "")).toLowerCase();
         
         for (var contact in contacts) {
            final name = contact.name?.toLowerCase();
            if (name != null && name.length > 3 && text.contains(name)) {
               // Found a match!
               item.linkedContactId = contact.id;
               await AgendaItem.db.updateRow(session, item);
               session.log('✅ Linked agenda to Contact: ${contact.name}');
               agendaCount++;
               break;
            }
         }
      }

      return 'Healing Complete! Linked $linkedCount interactions and $agendaCount agenda items.';

    } catch (e) {
      session.log('Error during healing: $e', level: LogLevel.error);
      return 'Error: $e';
    }
  }
}
