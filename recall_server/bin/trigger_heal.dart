import 'package:recall_client/recall_client.dart';
import 'package:serverpod_client/serverpod_client.dart';

Future<void> main() async {
  // Connect to local server
  final client = Client('http://localhost:8080/');
  
  print('Connecting to server to trigger data healing...');

  try {
    // Call the debug endpoint
    final result = await client.debug.healData();
    print('✅ Result: $result');
  } catch (e) {
    print('❌ Error calling healData: $e');
    print('Make sure the server is running on localhost:8080');
  } finally {
    client.close();
  }
}
