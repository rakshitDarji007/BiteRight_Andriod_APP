import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<String> generateMealPlan({
    required String goal,
    required List<String> restrictions,
    int days = 7,
  }) async {
    if (_apiKey.isEmpty) {
      return 'Error: API key not configured. Please contact developer.';
    }

    try {
      final restrictionsText = restrictions.isEmpty 
          ? "no specific dietary restrictions" 
          : "following dietary restrictions: ${restrictions.join(', ')}";

      final prompt = """
Create a detailed $days-day meal plan for someone whose goal is to $goal.
The person has $restrictionsText.

For each day, provide:
- Breakfast
- Lunch  
- Dinner
- 2 Snacks(morning and evening)

Include approximate calories for each meal and brief preparation instructions.
Format the response clearly with day-by-day breakdown.
""";

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      };

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        return content;
      } else {
        return 'Error generating meal plan: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: Cannot generate meal plan. Please check your internet connection.';
    }
  }
}