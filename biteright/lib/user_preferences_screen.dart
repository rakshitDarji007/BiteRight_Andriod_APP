import 'package:flutter/material.dart';
import 'meal_plan_screen.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  String? selectedGoal;
  List<String> selectedRestrictions = [];

  final List<String> goals = [
    'Lose Weight',
    'Gain Weight',
    'Build Muscle',
    'Maintain Weight',
    'General Health'
  ];

  final List<String> restrictions = [
    'Vegetarian',
    'Vegan',
    'Halal',
    'Kosher',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Preferences'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What\'s your goal?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...goals.map((goal) => RadioListTile<String>(
              title: Text(goal),
              value: goal,
              groupValue: selectedGoal,
              onChanged: (value) {
                setState(() {
                  selectedGoal = value;
                });
              },
            )),
            const SizedBox(height: 20),
            const Text(
              'Dietary Restrictions:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...restrictions.map((restriction) => CheckboxListTile(
              title: Text(restriction),
              value: selectedRestrictions.contains(restriction),
              onChanged: (checked) {
                setState(() {
                  if (checked ?? false) {
                    selectedRestrictions.add(restriction);
                  } else {
                    selectedRestrictions.remove(restriction);
                  }
                });
              },
            )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedGoal != null ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealPlanScreen(
                        goal: selectedGoal!,
                        restrictions: selectedRestrictions,
                      ),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Save Preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}