import '../lib/src/generated/protocol.dart';
import '../lib/src/generated/endpoints.dart';
import 'package:serverpod/serverpod.dart';

Future<void> main(List<String> args) async {
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: null, // No auth needed for this script
  );

  await pod.start();
  final session = await pod.createSession(enableLogging: true);

  print('🔎 Starting Data Healing Process...');
  
  try {
    // 1. Fetch orphaned interactions
    final interactions = await Interaction.db.find(
      session,
      where: (t) => t.linkedContactId.equals(null),
    );
    
    print('Found ${interactions.length} interactions with no linked contact.');

    // 2. Fetch all contacts
    final contacts = await Contact.db.find(session);
    print('Found ${contacts.length} existing contacts to match against.');
    
    int linkedCount = 0;

    for (var interaction in interactions) {
       final text = (interaction.snippet + " " + (interaction.subject ?? "")).toLowerCase();
       
       for (var contact in contacts) {
          final name = contact.name?.toLowerCase();
          if (name != null && name.length > 3 && text.contains(name)) {
             // Found a match!
             interaction.linkedContactId = contact.id;
             await Interaction.db.updateRow(session, interaction);
             print('✅ Linked interaction "${interaction.snippet.substring(0, 20)}..." to Contact: ${contact.name}');
             linkedCount++;
             break; // Stop after first match
          }
       }
    }
    
    // Also fix Agenda Items if any
    final agendaItems = await AgendaItem.db.find(
      session,
      where: (t) => t.linkedContactId.equals(null),
    );
    print('Found ${agendaItems.length} agenda items with no linked contact.');
    
    int agendaCount = 0;
    
    for (var item in agendaItems) {
       final text = (item.title + " " + (item.description ?? "")).toLowerCase();
       
       for (var contact in contacts) {
          final name = contact.name?.toLowerCase();
          if (name != null && name.length > 3 && text.contains(name)) {
             // Found a match!
             item.linkedContactId = contact.id;
             await AgendaItem.db.updateRow(session, item);
             print('✅ Linked agenda "${item.title}" to Contact: ${contact.name}');
             agendaCount++;
             break;
          }
       }
    }

    print('\n🎉 Healing Complete!');
    print('- Interactions Linked: $linkedCount');
    print('- Agenda Items Linked: $agendaCount');

  } catch (e) {
    print('❌ Error during healing: $e');
  } finally {
    session.close();
    await pod.shutdown();
  }
}
