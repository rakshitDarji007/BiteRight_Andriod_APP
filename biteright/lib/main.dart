import 'package:flutter/material.dart';

void main() {
  runApp(const BiteRightApp());
}

class BiteRightApp extends StatelessWidget {
  const BiteRightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiteRight',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiteRight'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to BiteRight!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Healthy Eating Starts Here!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}