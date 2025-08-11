import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'meal_plan_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<List<Map<String, dynamic>>> _mealPlansFuture;

  @override
  void initState() {
    super.initState();
    _mealPlansFuture = _fetchMealPlans();
  }

  Future<List<Map<String, dynamic>>> _fetchMealPlans() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }
    final response = await supabase
        .from('meal_plans')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Saved Plans'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _mealPlansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final mealPlans = snapshot.data;
          if (mealPlans == null || mealPlans.isEmpty) {
            return const Center(
              child: Text(
                'You have no saved meal plans yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: mealPlans.length,
            itemBuilder: (context, index) {
              final plan = mealPlans[index];
              final goal = plan['goal'] as String;
              final restrictions =
                  List<String>.from(plan['dietary_restrictions'] ?? []);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(goal),
                  subtitle: Text(restrictions.join(', ')),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MealPlanScreen(
                          mealPlanJson: jsonEncode(plan['plan_content']),
                          goal: goal,
                          restrictions: restrictions,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}