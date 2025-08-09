import 'dart:convert';
import 'package:flutter/material.dart';
import 'main.dart';

class MealPlanScreen extends StatelessWidget {
  final String mealPlanJson;
  final String goal;
  final List<String> restrictions;

  const MealPlanScreen({
    super.key,
    required this.mealPlanJson,
    required this.goal,
    required this.restrictions,
  });

  Future<void> _saveMealPlan(BuildContext context) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      await supabase.from('meal_plans').insert({
        'user_id': user.id,
        'plan_content': jsonDecode(mealPlanJson),
        'goal': goal,
        'dietary_restrictions': restrictions,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan saved successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save meal plan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> mealPlan = jsonDecode(mealPlanJson);
    final days = mealPlan.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Meal Plan'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveMealPlan(context),
            tooltip: 'Save Plan',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final dailyPlan = mealPlan[day];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${index + 1}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  _MealDetail(
                    mealName: 'Breakfast',
                    description: dailyPlan['breakfast']['description'],
                    calories: dailyPlan['breakfast']['calories'],
                  ),
                  _MealDetail(
                    mealName: 'Lunch',
                    description: dailyPlan['lunch']['description'],
                    calories: dailyPlan['lunch']['calories'],
                  ),
                  _MealDetail(
                    mealName: 'Dinner',
                    description: dailyPlan['dinner']['description'],
                    calories: dailyPlan['dinner']['calories'],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MealDetail extends StatelessWidget {
  final String mealName;
  final String description;
  final int calories;

  const _MealDetail({
    required this.mealName,
    required this.description,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(description),
          const SizedBox(height: 4),
          Text(
            'Approx. $calories calories',
            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}