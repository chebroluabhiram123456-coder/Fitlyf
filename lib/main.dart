import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

// The main function MUST be async to use 'await'
void main() async {
  // 1. This line is ESSENTIAL. It ensures Flutter is ready before you use any plugins.
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. This line waits for Firebase to connect before the app starts.
  // This is the most likely cause of the black screen crash.
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutProvider(),
      child: MaterialApp(
        title: 'Fitlyf',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black, // A solid default background
          primaryColor: Colors.greenAccent,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white)
          ),
          colorScheme: const ColorScheme.dark(
            primary: Colors.greenAccent,
            secondary: Colors.greenAccent,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
