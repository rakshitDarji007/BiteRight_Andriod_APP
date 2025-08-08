import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  String? _selectedGoal;
  final List<String> _selectedRestrictions = [];
  bool _isLoading = false;

  final List<String> _goals = [
    'Lose Weight',
    'Gain Weight',
    'Build Muscle',
    'Maintain Weight',
    'General Health'
  ];

  final List<String> _restrictions = [
    'Vegetarian',
    'Vegan',
    'Halal',
    'Kosher',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free'
  ];

  Future<void> _getInitialPreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('profiles')
          .select('goal, dietary_restrictions')
          .eq('id', userId)
          .single();

      if (response != null) {
        setState(() {
          _selectedGoal = response['goal'] as String?;
          final restrictions = response['dietary_restrictions'] as List?;
          if (restrictions != null) {
            _selectedRestrictions.clear();
            _selectedRestrictions.addAll(restrictions.map((e) => e.toString()));
          }
        });
      }
    } catch (error) {

    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getInitialPreferences();
  }

  Future<void> _savePreferences() async {
    final user = supabase.auth.currentUser;
    if (user == null || _selectedGoal == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.from('profiles').upsert({
        'id': user.id,
        'goal': _selectedGoal,
        'dietary_restrictions': _selectedRestrictions,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved!')),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sorry, unexpected error occurred.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Preferences'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _selectedGoal == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'What is your primary goal?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ..._goals.map((goal) => RadioListTile<String>(
                        title: Text(goal),
                        value: goal,
                        groupValue: _selectedGoal,
                        onChanged: (value) {
                          setState(() {
                            _selectedGoal = value;
                          });
                        },
                      )),
                  const Divider(height: 30),
                  const Text(
                    'Any dietary restrictions?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView(
                      children: _restrictions
                          .map((restriction) => CheckboxListTile(
                                title: Text(restriction),
                                value:
                                    _selectedRestrictions.contains(restriction),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedRestrictions.add(restriction);
                                    } else {
                                      _selectedRestrictions
                                          .remove(restriction);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _selectedGoal == null || _isLoading ? null : _savePreferences,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          textStyle: const TextStyle(fontSize: 16)),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ))
                          : const Text('Save Preferences'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}