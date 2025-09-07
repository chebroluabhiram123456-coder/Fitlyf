import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/screens/home_screen.dart'; // Or your initial screen
import 'package:google_fonts/google_fonts.dart'; // <-- IMPORT GOOGLE FONTS
import 'package:firebase_core/firebase_core.dart'; // Make sure you have this import

void main() async {
  // These two lines are important for Firebase to work correctly
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using ChangeNotifierProvider to make the WorkoutProvider available to the whole app
    return ChangeNotifierProvider(
      create: (context) => WorkoutProvider(),
      child: MaterialApp(
        title: 'Fitlyf',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.greenAccent,
          
          // *** THIS APPLIES THE FONT THEME ***
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white)
          ),
          
          colorScheme: const ColorScheme.dark(
            primary: Colors.greenAccent,
            secondary: Colors.greenAccent,
          ),
        ),
        home: const HomeScreen(), // Set your starting screen here
      ),
    );
  }
}
