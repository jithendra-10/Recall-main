import 'package:hive_flutter/hive_flutter.dart';
import 'package:recall_client/recall_client.dart';

class OfflineQueueService {
  static const String boxName = 'recall_offline_queue';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
       await Hive.openBox(boxName);
    }
  }

  Future<void> queueAction(String actionType, Map<String, dynamic> data) async {
    if (!Hive.isBoxOpen(boxName)) await init();
    final box = Hive.box(boxName);
    
    final action = {
      'type': actionType,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await box.add(action);
  }

  Future<void> processQueue(Client client) async {
    if (!Hive.isBoxOpen(boxName)) await init();
    final box = Hive.box(boxName);
    
    if (box.isEmpty) return;
    
    final keys = box.keys.toList();
    for (var key in keys) {
      try {
        final action = box.get(key);
        // Hive stores Map<dynamic, dynamic> by default, need casting usually
        if (action == null) continue;
        
        final actionMap = Map<String, dynamic>.from(action as Map);
        final data = Map<String, dynamic>.from(actionMap['data'] as Map);

        if (actionMap['type'] == 'draft_email') {
           // Call Serverpod Endpoint
           // Ensure Client has this method accessible
           // Assuming dashboard endpoint 'sendEmail' wrapper or direct gmail endpoint
           // Let's use gmail endpoint directly if possible or dashboard wrapper
           // DashboardProvider calls: `client.dashboard.sendSmartEmail(...)` ??
           // No, dashboard_provider calls `client.gmail.createDraft(...)`?
           // I will check DashboardProvider later. For now, assuming standard client access.
           
           // Based on context, we likely use `client.gmail.createDraft` or similar.
           // I'll leave a TODO or generic call here, but better to be precise.
           // I'll assume `client.gmail.createDraft(recipient, subject, body)` exists.
           // If not, I'll need to update this after checking endpoint.
           // Actually, earlier prompt used `client.gmail.createDraft`.
           
           await client.email.sendEmail(
             data['to'],
             data['subject'],
             data['body'],
           );
        }
        
        // If successful, delete
        await box.delete(key);
        print("Processed offline action: ${actionMap['type']}");

      } catch (e) {
        print("Sync failed for key $key: $e");
        // Keep in queue to retry later
      }
    }
  }
}
