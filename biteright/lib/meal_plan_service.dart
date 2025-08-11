import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MealPlanService {
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<String> generateMealPlan({
    required String goal,
    required List<String> restrictions,
  }) async {
    print('Using Gemini API Key $_apiKey');
    if (_apiKey == null) {
      throw Exception('API key is not configured');
    }
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_apiKey');

    final prompt = """
    Generate a 3-day meal plan for a person whose goal is to '$goal'.
    The person has the following dietary restrictions: ${restrictions.isEmpty ? "None" : restrictions.join(', ')}.
    Provide a detailed plan for Breakfast, Lunch, and Dinner for each of the 3 days.
    Include estimated calories for each meal.
    Format the output as a valid JSON object only, with no other text or markdown.
    The JSON object should have keys "day1", "day2", "day3". Each day should be an object with keys "breakfast", "lunch", "dinner".
    Each meal should be an object with "description" and "calories" keys.
    Example for one day: {"breakfast": {"description": "Oatmeal with berries", "calories": 300}, "lunch": ...}
    """;

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final textContent = 
          responseBody['candidates'][0]['content']['parts'][0]['text'];
      return textContent;
    } else {
      throw Exception('Failed to generate meal plan: ${response.body}');
    }
  }
}