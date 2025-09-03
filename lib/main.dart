import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';
import 'screens/weekly_plan_screen.dart';
// Add other screen imports as needed

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutProvider(),
      child: MaterialApp(
        title: 'FitLyf',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blueAccent,
          scaffoldBackgroundColor: Colors.grey[900],
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(), // FIX: Removed 'const'
          '/weekly-plan': (context) => WeeklyPlanScreen(), // FIX: Removed 'const'
          // Add other routes here if you have them
        },
      ),
    );
  }
}
