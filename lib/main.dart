import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/screens/home_screen.dart';
import 'package:fitlyf/screens/progress_screen.dart';
import 'package:fitlyf/screens/weekly_plan_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => WorkoutProvider(),
      child: MaterialApp(
        title: 'FitLfy',
        theme: ThemeData(
          // Set brightness to dark to ensure text and icons default to light colors
          brightness: Brightness.dark, 
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Set canvas color to transparent for our gradient background
          canvasColor: Colors.transparent, 
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const ProgressScreen(), // Assuming you have this screen
    const WeeklyPlanScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. WRAP THE SCAFFOLD IN A CONTAINER WITH THE GRADIENT
    // This makes the background permanent across all screens.
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF2D1458), Color(0xFF1A0E38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        // 2. MAKE THE SCAFFOLD TRANSPARENT TO SHOW THE GRADIENT
        backgroundColor: Colors.transparent,
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        // 3. STYLE THE BOTTOM NAVIGATION BAR
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Make it transparent
          elevation: 0, // Remove the shadow
          selectedItemColor: Colors.white, // Color for the active icon
          unselectedItemColor: Colors.white70, // Color for inactive icons
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Plan',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
