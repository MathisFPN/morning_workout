import 'package:flutter/material.dart';
import 'package:morning_workout/screens/home_page.dart';

void main() {
  runApp(const MorningWorkoutApp());
}

class MorningWorkoutApp extends StatelessWidget {
  const MorningWorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Workout',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey[900],
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple[300]!,
          secondary: Colors.deepPurple[300]!,
          surface: Colors.grey[850]!,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Assure-toi d'ajouter la police si tu veux
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}