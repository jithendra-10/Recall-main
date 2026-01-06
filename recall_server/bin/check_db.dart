import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:recall_server/src/generated/protocol.dart';
import 'package:recall_server/src/generated/endpoints.dart';

void main(List<String> args) async {
  // Initialize Serverpod
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  // Start (connects to DB)
  await pod.start();
  
  print('\n\n========== DATABASE CHECK ==========');
  
  final session = await pod.createSession(enableLogging: false);
  try {
    // Check for ANY user config
    final configs = await UserConfig.db.find(session);
    print('Total UserConfigs: ${configs.length}');
    for (var c in configs) {
        print(' - UserConfig ID: ${c.id}, UserInfoId: ${c.userInfoId}, HasToken: ${c.googleRefreshToken != null}');
    }

    // Check Contacts for User 1
    final contacts = await Contact.db.find(session, where: (t) => t.ownerId.equals(1));
    print('\nContacts for User 1: ${contacts.length}');
    for (var c in contacts) {
        print(' - [${c.id}] ${c.name} <${c.email}> (Score: ${c.healthScore})');
    }

    // Check Interactions for User 1
    final interactions = await Interaction.db.find(session, where: (t) => t.ownerId.equals(1), limit: 5);
    final count = await Interaction.db.count(session, where: (t) => t.ownerId.equals(1));
    print('\nInteractions for User 1: Total $count');
    if (interactions.isNotEmpty) {
        print('Sample Interaction:');
        print(' - ${interactions.first.date}: ${interactions.first.subject}');
    } else {
        print('No interactions found.');
    }

  } catch (e, stack) {
      print('Error querying DB: $e');
      print(stack);
  } finally {
      print('====================================\n');
      session.close();
      exit(0);
  }
}
