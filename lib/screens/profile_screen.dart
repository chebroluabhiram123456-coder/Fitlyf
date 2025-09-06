import 'package:flutter/material.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/exercise_library_screen.dart';
import 'package:fitlyf/screens/workout_log_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Link to Exercise Library
          _buildProfileMenuItem(
            context: context,
            icon: Icons.list_alt,
            title: 'Exercise Library',
            subtitle: 'View all your exercises',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExerciseLibraryScreen()),
              );
            },
          ),
          // Link to Workout Log
          _buildProfileMenuItem(
            context: context,
            icon: Icons.history,
            title: 'Workout Log',
            subtitle: 'See your past workouts',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkoutLogScreen()),
              );
            },
          ),
          // Placeholder for Settings
          _buildProfileMenuItem(
            context: context,
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () {
              // TODO: Navigate to settings screen
            },
          ),
          const SizedBox(height: 30),
          // Placeholder for Log Out
          TextButton(
            onPressed: () {
              // TODO: Implement logout functionality
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: GestureDetector(
        onTap: onTap,
        child: FrostedGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
