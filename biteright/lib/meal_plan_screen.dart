import 'package:flutter/material.dart';
import 'gemini_service.dart';

class MealPlanScreen extends StatefulWidget {
  final String goal;
  final List<String> restrictions;

  const MealPlanScreen({
    super.key,
    required this.goal,
    required this.restrictions,
  });

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  String mealPlan = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    generateMealPlan();
  }

  Future<void> generateMealPlan() async {
    setState(() {
      isLoading = true;
    });

    final plan = await GeminiService.generateMealPlan(
      goal: widget.goal,
      restrictions: widget.restrictions,
    );

    setState(() {
      mealPlan = plan;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Meal Plan'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : generateMealPlan,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.black),
                  SizedBox(height: 16),
                  Text('Generating your personalized meal plan...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goal: ${widget.goal}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.restrictions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Restrictions: ${widget.restrictions.join(', ')}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      mealPlan.isEmpty ? 'No meal plan generated yet.' : mealPlan,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}