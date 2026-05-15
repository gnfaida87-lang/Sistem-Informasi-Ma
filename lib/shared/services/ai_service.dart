import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/system_admin/services/system_service.dart';
import 'package:flutter/foundation.dart';
import '../../features/system_admin/models/system_settings_model.dart';
import 'package:flutter/foundation.dart';

class AIService {
  final SystemService _systemService = SystemService();

  /// Mengambil respon dari AI (OpenAI atau Gemini)
  Future<String> getChatResponse({
    required String assistantName,
    required String prompt,
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      final settings = await _systemService.fetchSettings();
      
      bool isGuru = assistantName.toLowerCase().contains('guru');
      String? engine = isGuru ? settings.guruAiEngine : settings.belajarAiEngine;
      List<String> encodedKeys = isGuru ? settings.guruAiKeys : settings.belajarAiKeys;

      if (encodedKeys.isEmpty) {
        return "API Key untuk $assistantName belum dikonfigurasi oleh Admin.";
      }

      // Decode key (Simple Base64 as per IntegrationScreen logic)
      String apiKey = _decodeKey(encodedKeys.first);
      
      if (engine?.contains('OpenAI') == true) {
        return await _callOpenAI(apiKey, prompt, history ?? []);
      } else if (engine?.contains('Gemini') == true) {
        return await _callGemini(apiKey, prompt, history ?? []);
      } else {
        return "Engine AI ($engine) tidak dikenali atau belum didukung.";
      }
    } catch (e) {
      debugPrint("Error AIService: $e");
      return "Maaf, terjadi kesalahan teknis saat menghubungi AI: $e";
    }
  }

  String _decodeKey(String encoded) {
    try {
      return utf8.decode(base64.decode(encoded));
    } catch (e) {
      return encoded; // Fallback if not base64
    }
  }

  Future<String> _callOpenAI(String apiKey, String prompt, List<Map<String, dynamic>> history) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    
    final messages = [
      {'role': 'system', 'content': 'Anda adalah asisten AI di Sistem Informasi Madrasah. Berikan jawaban yang sopan dan membantu.'},
      ...history.map((m) => {
        'role': m['role'] == 'user' ? 'user' : 'assistant',
        'content': m['text'],
      }),
      {'role': 'user', 'content': prompt},
    ];

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o', // Default to 4o
        'messages': messages,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw "OpenAI Error: ${response.body}";
    }
  }

  Future<String> _callGemini(String apiKey, String prompt, List<Map<String, dynamic>> history) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$apiKey');

    final contents = [
      ...history.map((m) => {
        'role': m['role'] == 'user' ? 'user' : 'model',
        'parts': [{'text': m['text']}]
      }),
      {
        'role': 'user',
        'parts': [{'text': prompt}]
      },
    ];

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 800,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw "Gemini Error: ${response.body}";
    }
  }
}
