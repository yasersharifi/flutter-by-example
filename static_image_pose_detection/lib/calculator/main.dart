import 'package:flutter/material.dart';

import 'calculator_screen.dart';

void main() {
  runApp(const MyApp(title: 'Calculator App'));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData.dark(),
      home: Scaffold(
        // App bar
        appBar: AppBar(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          backgroundColor: Colors.deepPurple,

        ),

        // Body
        body: CalculatorScreen(),
      ),
    );
  }
}


