import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

/// AI Service supporting Gemini and Groq (Llama 3)
class GeminiService {
  static final _env = DotEnv(includePlatformEnvironment: true)..load();
  
  // Gemini Configuration
  static String? get _geminiKey => _env['GEMINI_API_KEY'];
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  // Groq Configuration
  static String? get _groqKey => _env['GROQ_API_KEY'];
  static const String _groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Helper to determine active provider for fast chat
  static bool get _useGroq => _groqKey != null && _groqKey!.isNotEmpty;

  // --------------------------------------------------------------------------------------
  // EMAIL ANALYSIS (Gemini Default)
  // --------------------------------------------------------------------------------------

  /// Analyze email content using strict logic and return structured data
  static Future<Map<String, dynamic>?> analyzeEmail(String content, String sender, String recipient, bool isSent, DateTime emailDate) async {
    // Currently defaulting to Gemini as it handles complex instruction well.
    // Can be ported to Llama 3 on Groq if needed.
    return _analyzeEmailGemini(content, sender, recipient, isSent, emailDate);
  }

  static Future<Map<String, dynamic>?> _analyzeEmailGemini(String content, String sender, String recipient, bool isSent, DateTime emailDate) async {
    final prompt = '''You are the intelligence layer of an application that reads a user's Gmail in real time.
Your task is to process raw Gmail messages and convert them into meaningful, structured memory for the app.

Rules:
1. You must read only real email content obtained dynamically via Gmail API.
2. Never invent, assume, or generate static or demo data.
3. Every output must be directly derived from actual email content.
4. If an email has no meaningful human intent, you must ignore it completely (set ignore=true).

Email Filtering Logic:
- Identify whether the email is human-written or automated.
- Ignore newsletters, promotions, system notifications, receipts, job feeds, alerts, marketing emails, and bulk mail.
- Process only emails that contain personal, conversational, professional, or intentional human communication.

Content Understanding:
- Read the full email body and subject.
- Detect intent such as: discussion, follow-up, request, commitment, decision, reminder, emotional context, or planning.
- Identify who the interaction is with and the direction of communication (sent or received).
- Detect any promises, deadlines, or implied future actions.

Event Extraction Logic:
- If the email discusses a specific meeting, appointment, or scheduled event, extract it.
- Resolving Relative Dates: The email was sent on ${emailDate.toIso8601String()}. Use this as the anchor to resolve terms like "tomorrow", "next Tuesday", "in 2 days".
- If a specific time is mentioned, use it. If no time is mentioned but a day is, assume start of business (9am) or keep time null if schema allows. For this schema, infer a likely time if vague.
- "priority": "high" if urgent/important client, "normal" otherwise.

Summarization Rules:
- Summaries must be short, factual, and neutral.
- Do not rewrite the email.
- Do not add interpretation beyond what is explicitly or clearly implied.
- Capture only what is important for remembering later.
- Remove greetings, signatures, links, formatting, and repeated content.
- Never include promotional or decorative text.

Input Metadata:
From: $sender
To: $recipient
Direction: ${isSent ? 'Sent' : 'Received'}
Sent Date: ${emailDate.toIso8601String()}

Input Content:
$content

Output Structure (JSON):
Return a valid JSON object. Do not include markdown code blocks.
{
  "ignore": boolean,
  "summary": "One concise memory summary (if not ignored)",
  "intent_tags": ["string", "string"],
  "needs_follow_up": boolean,
  "extracted_event": {
     "found": boolean,
     "title": "Short event title",
     "start_time": "ISO8601 String or null",
     "end_time": "ISO8601 String or null", 
     "priority": "high" | "normal" | "low"
  }
}
''';

    try {
      final apiKey = _geminiKey;
      if (apiKey == null) {
          print('Gemini API Key missing for Email Analysis');
          return null;
      }
      
      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/gemini-2.0-flash-lite-preview-02-05:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 500,
            'responseMimeType': 'application/json',
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (text != null) {
          try {
            final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
            final jsonResult = jsonDecode(cleanText);
            
            if (jsonResult['ignore'] == true) {
              return null;
            }
            
            return jsonResult;
          } catch (e) {
             print('Gemini JSON parsing error: $e');
             return null;
          }
        }
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Gemini analysis error: $e');
    }
    
    return null;
  }

  // --------------------------------------------------------------------------------------
  // DRAFT EMAIL (Gemini Default)
  // --------------------------------------------------------------------------------------

  static Future<String> generateDraftEmail({
    required String contactName,
    required String lastTopic,
    required int daysSilent,
    required List<String> recentInteractions,
  }) async {
      if (_useGroq) {
        return _generateDraftGroq(contactName: contactName, lastTopic: lastTopic, daysSilent: daysSilent, recentInteractions: recentInteractions);
      }
      return _generateDraftGemini(contactName: contactName, lastTopic: lastTopic, daysSilent: daysSilent, recentInteractions: recentInteractions);
  }

  static Future<String> _generateDraftGroq({
    required String contactName,
    required String lastTopic,
    required int daysSilent,
    required List<String> recentInteractions,
  }) async {
    final context = recentInteractions.take(3).join('\n');
    
    final systemPrompt = '''You are an expert personal communication assistant. Your goal is to draft a PERFECTLY CONTEXTUAL email.
    
    TASK:
    1. CLASSIFY THE RECIPIENT:
       - Is this a "SERVICE/COMPANY"? (Formal, direct)
       - Is this a "RECRUITER/PROFESSIONAL"? (Polite, professional)
       - Is this a "PERSONAL FRIEND/FAMILY"? (Warm, casual)
       
    2. DETERMINE THE GOAL based on "Last Topic".
       
    3. GENERATE THE DRAFT (Strict Rules):
       - IF SERVICE/COMPANY: Write a formal inquiry.
       - IF PROFESSIONAL: Write a polite follow-up.
       - IF PERSONAL: Write a casual catch-up.
    
    4. OUTPUT:
       - Return ONLY the email body text. No "Subject:" line, no explanations.
    ''';

    final userContent = '''
    Contact: $contactName
    Last Topic: $lastTopic
    Days Silent: $daysSilent
    History:
    $context
    ''';

    try {
      final response = await http.post(
        Uri.parse(_groqBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userContent}
          ],
          'temperature': 0.4,
          'max_completion_tokens': 400,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'];
        return text?.trim() ?? _fallbackDraft(contactName, lastTopic);
      }
    } catch (e) {
      print('Groq draft error: $e');
    }
    return _fallbackDraft(contactName, lastTopic);
  }

  static Future<String> _generateDraftGemini({
    required String contactName,
    required String lastTopic,
    required int daysSilent,
    required List<String> recentInteractions,
  }) async {
    final context = recentInteractions.take(3).join('\n');
    
    final prompt = '''You are an expert personal communication assistant. Your goal is to draft a PERFECTLY CONTEXTUAL email.
    
    context:
    Contact Name: $contactName
    Last Topic: $lastTopic
    Days Silent: $daysSilent
    Interaction History Snippets:
    $context
    
    TASK:
    1. CLASSIFY THE RECIPIENT:
       - Is this a "SERVICE/COMPANY" (e.g., Amazon, Bank, LinkedIn, Newsletter, Support Department)?
       - Is this a "RECRUITER/PROFESSIONAL" (e.g., Hiring Manager, Colleague, Client)?
       - Is this a "PERSONAL FRIEND/FAMILY"?
       
    2. DETERMINE THE GOAL based on "$lastTopic":
       - If usage implies a transactional update (Order #, Invoice, Reset Password), the draft should be a generic "Thank you" or "Issue Resolved".
       - If usage implies a lost connection, the draft should be a reconnection.
       
    3. GENERATE THE DRAFT (Strict Rules):
       - IF SERVICE/COMPANY: Write a formal, direct inquiry or simple acknowledgment. DO NOT ask for coffee. DO NOT say "Long time no see". Example: "Hello, regarding the recent update on $lastTopic, could you clarify..."
       - IF PROFESSIONAL: Write a polite, professional follow-up. "Hi $contactName, hope you are well. Following up on $lastTopic..."
       - IF PERSONAL: Write a warm, casual catch-up. "Hey $contactName! Been a while ($daysSilent days). Saw something about $lastTopic and thought of you. Coffee soon?"
    
    4. OUTPUT:
       - Return ONLY the email body text. No "Subject:" line, no explanations.
       - Verify: If recipient is Amazon/Service, ensure NO "quick call" invites.
    ''';

    try {
      final apiKey = _geminiKey;
      if (apiKey == null) return _fallbackDraft(contactName, lastTopic);

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/gemini-2.0-flash-lite-preview-02-05:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {
            'temperature': 0.4, 
            'maxOutputTokens': 400,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text?.trim() ?? _fallbackDraft(contactName, lastTopic);
      }
    } catch (e) {
      print('Gemini draft error: $e');
    }
    
    return _fallbackDraft(contactName, lastTopic);
  }

  static String _fallbackDraft(String name, String topic) {
    return '''Hi $name,

I hope you're doing well! I was just thinking about $topic and it reminded me of you.

Would love to catch up soon - are you free for a quick coffee or call this week?

Best regards''';
  }

  // --------------------------------------------------------------------------------------
  // EMBEDDINGS (Gemini Only - for now)
  // --------------------------------------------------------------------------------------

  static Future<List<double>> generateEmbedding(String text) async {
    try {
      final apiKey = _geminiKey;
      if (apiKey == null) return List.filled(768, 0.0);

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/text-embedding-004:embedContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'models/text-embedding-004',
          'content': {
            'parts': [
              {'text': text}
            ]
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final embeddings = data['embedding']?['values'] as List<dynamic>?;
        if (embeddings != null) {
          return embeddings.map((e) => (e as num).toDouble()).toList();
        }
      } else {
        print('Gemini embedding error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Gemini embedding error: $e');
    }
    
    // Return zero vector as fallback
    return List.filled(768, 0.0);
  }

  // --------------------------------------------------------------------------------------
  // RAG RESPONSE (Hybrid: Groq > Gemini)
  // --------------------------------------------------------------------------------------

  static Future<String> generateRagResponse({
    required String query,
    required List<String> retrievedContexts,
  }) async {
    if (_useGroq) {
      return _generateRagGroq(query, retrievedContexts);
    }
    return _generateRagGemini(query, retrievedContexts);
  }

  static Future<String> _generateRagGroq(String query, List<String> retrievedContexts) async {
    final context = retrievedContexts.isEmpty 
        ? "No recent context found." 
        : retrievedContexts.join('\n\n');

    final systemPrompt = '''You are 'Recall', a sophisticated, private, and intelligent personal relationship butler.
    
CONTEXT:
$context

USER QUERY: $query

RULES:
1. Be concise, polite, and helpful (Butler Persona).
2. Answer based on CONTEXT. If unknown, say so.
3. Never reveal secrets.
''';

    try {
      final response = await http.post(
        Uri.parse(_groqBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': query}
          ],
          'temperature': 0.3,
          'max_completion_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? "Sorry, no response from Groq.";
      } else {
        return "Groq API Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Groq Error: $e";
    }
  }

  static Future<String> _generateRagGemini(String query, List<String> retrievedContexts) async {
    if (retrievedContexts.isEmpty) {
      return "I don't have any relevant information about that in your communication history.";
    }

    final context = retrievedContexts.join('\n\n');
    
    final prompt = '''You are 'Recall', a sophisticated, private, and intelligent personal relationship butler. Your job is to help the user manage their professional network and remember key details from their life.

YOUR BEHAVIORAL RULES:
1. The Persona: You are polite, professional, and concise. Speak like a high-end butler.
2. Handling Greetings: If the user says "Hi", "Hello", or "Good Morning", respond warmly and ask how you can assist.
3. Using Context:
   - If the Context contains the answer, summarize it clearly.
   - If the Context is empty or irrelevant, simply state: "I don't recall seeing that in your recent emails."
4. Privacy & Security (CRITICAL):
   - You are a Vault. NEVER reveal passwords, API keys, bank PINs, or highly sensitive secrets.
5. Agency: If the user asks you to "Draft an email" or "Remind me", acknowledge the request.

Refrieved Context:
$context

Current User Query: $query

Answer as the Butler:''';

    try {
      final apiKey = _geminiKey;
      if (apiKey == null) return "Error: GEMINI_API_KEY missing.";

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/gemini-2.0-flash-lite-preview-02-05:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 500,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text?.trim() ?? 'Sorry, I could not generate a response.';
      } else {
        return 'Gemini API Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      print('Gemini RAG error: $e');
      return 'Sorry, I encountered an error processing your request: $e';
    }
  }

  // --------------------------------------------------------------------------------------
  // VOICE NOTE ANALYSIS (Hybrid: Groq > Gemini)
  // --------------------------------------------------------------------------------------

  static Future<Map<String, dynamic>?> analyzeVoiceNote(String transcript, DateTime now) async {
    if (_useGroq) {
      return _analyzeVoiceNoteGroq(transcript, now);
    }
    return _analyzeVoiceNoteGemini(transcript, now);
  }

  static Future<Map<String, dynamic>?> _analyzeVoiceNoteGroq(String transcript, DateTime now) async {
    final systemPrompt = '''You are an AI assistant for Recall. Analyze the transcript.
Context Time: ${now.toIso8601String()}
Output strict JSON format:
{
  "summary": "string",
  "contacts": [{"name": "string", "is_new": bool, "context": "string"}],
  "agenda_items": [{"title": "string", "start_time": "ISO8601", "priority": "high/normal"}]
}''';

    try {
       final response = await http.post(
        Uri.parse(_groqBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': transcript}
          ],
          'response_format': {'type': 'json_object'},
        }),
      );
      
      if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices'][0]['message']['content'];
          return jsonDecode(content);
      }
    } catch (e) {
        print("Groq Voice Error: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> _analyzeVoiceNoteGemini(String transcript, DateTime now) async {
    final prompt = ''' You are an AI assistant for a relationship management app called Recall.
Your task is to analyze a raw voice note transcript from a user and extract meaningful actions and entities.

Input Transcript:
"$transcript"

Context:
Current Time: ${now.toIso8601String()}

Extraction Goals:
1. **Identify Contacts**: Is the user talking about a person? Extract their name and any relationship context.
2. **Identify Agenda/Events**: Is the user asking to be reminded of something or setting a meeting?
3. **Identify Context**: What is the core memory or note here?

Resolving Dates:
- "Tomorrow at 5pm" means ${now.add(const Duration(days: 1)).toString().split(' ')[0]} 17:00:00.
- "Next Monday" means the coming Monday relative to ${now.weekday}.

Output JSON Structure:
{
  "summary": "Short, cleaned up note of what the user said (e.g. 'Reminder to mail John about the project')",
  "contacts": [
    {
      "name": "Full Name or First Name",
      "is_new": boolean (true if context implies we don't know them, e.g. "I met a new guy"),
      "context": "Relationship or role mentioned (e.g. 'met at conference', 'new client')"
    }
  ],
  "agenda_items": [
    {
       "title": "Event title",
       "start_time": "ISO8601 String",
       "priority": "high" | "normal" | "low"
    }
  ]
}
Return valid JSON only.
''';

    try {
      final apiKey = _geminiKey;
      if (apiKey == null) return null;

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/gemini-2.0-flash-lite-preview-02-05:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
             'temperature': 0.1,
             'responseMimeType': 'application/json',
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(cleanJson);
      } else {
        print('Gemini API Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Gemini Service Error: $e');
      return null;
    }
  }
}
