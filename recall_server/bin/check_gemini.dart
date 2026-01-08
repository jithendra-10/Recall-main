import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

void main() async {
  // 1. Load Environment Variables
  final envFile = File('config/passwords.yaml'); 
  // Note: passwords.yaml usually has secrets, but here we might rely on .env or hardcoded for this check if .env is missing.
  // Actually, GeminiService loads from .env. Let's try .env first.
  
  var apiKey = '';
  final env = DotEnv(includePlatformEnvironment: true)..load();
  apiKey = env['GEMINI_API_KEY'] ?? '';

  if (apiKey.isEmpty) {
     print('❌ GEMINI_API_KEY not found in .env');
     print('Please edit this script and paste your key strictly for testing if needed.');
     return;
  }

  print('🔍 Checking Gemini Models for Key: ${apiKey.substring(0, 5)}...');

  // 2. List Models
  final url = 'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey';
  
  try {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final models = json['models'] as List;
      
      print('\n✅ Available Models:');
      for (var m in models) {
        final name = m['name'].toString().replaceFirst('models/', '');
        final methods = m['supportedGenerationMethods'];
        print('- $name (Methods: $methods)');
      }
      print('\n👉 Please pick a model from above that supports "generateContent".');
    } else {
      print('\n❌ Error Listing Models:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('❌ Network/Script Error: $e');
  }
}
