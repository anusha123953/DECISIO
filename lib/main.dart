
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/create_decision_screen.dart';

void main() {
  runApp(const DecisioApp());
}

class DecisioApp extends StatelessWidget {
  const DecisioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'DECISIO',

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        scaffoldBackgroundColor:
            const Color(0xFF10111A),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF10111A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1D1E2B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF343448),
            ),
          ),
        ),
      ),

      home: const HomeScreen(),

      routes: {
        '/create': (context) =>
            const CreateDecisionScreen(),
      },
    );
  }
}
