import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/screens/home_screen.dart';
import 'package:fitlyf/screens/progress_screen.dart';
import 'package:fitlyf/screens/weekly_plan_screen.dart';
import 'package:fitlyf/screens/profile_screen.dart';

// THE FIX 1: The main function must be 'async' to initialize Firebase.
void main() async {
  // This is required to ensure that native code can be called before runApp.
  WidgetsFlutterBinding.ensureInitialized();
  // This line initializes the Firebase connection.
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.dark();
    return ChangeNotifierProvider(
      create: (ctx) => WorkoutProvider(),
      child: MaterialApp(
        title: 'Fitlyf',
        // THE FIX 2: This is the correct, stable way to apply a global font theme.
        theme: base.copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
          primaryColor: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.transparent,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            type: BottomNavigationBarType.fixed,
          ),
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
    const ProgressScreen(),
    const WeeklyPlanScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF2D1458), Color(0xFF1A0E38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Plan'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
