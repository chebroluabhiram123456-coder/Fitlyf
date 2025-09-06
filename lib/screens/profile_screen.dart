import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/exercise_library_screen.dart';
import 'package:fitlyf/screens/workout_log_screen.dart';
import 'package:fitlyf/screens/settings_screen.dart'; // <-- IMPORT THE NEW SCREEN
import 'package:fitlyf/helpers/fade_route.dart'; // Import for smooth transitions

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      Provider.of<WorkoutProvider>(context, listen: false)
          .updateProfilePicture(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(workoutProvider.profileImagePath, workoutProvider.userName),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    children: [
                      _buildProfileMenuItem(
                        context: context,
                        icon: Icons.list_alt,
                        title: 'Exercise Library',
                        subtitle: 'View all your exercises',
                        onTap: () {
                          Navigator.push(context, FadePageRoute(child: const ExerciseLibraryScreen()));
                        },
                      ),
                      _buildProfileMenuItem(
                        context: context,
                        icon: Icons.history,
                        title: 'Workout Log',
                        subtitle: 'See your past workouts',
                        onTap: () {
                           Navigator.push(context, FadePageRoute(child: const WorkoutLogScreen()));
                        },
                      ),
                      // THE FIX 1: Make the settings button functional.
                      _buildProfileMenuItem(
                        context: context,
                        icon: Icons.settings,
                        title: 'Settings',
                        subtitle: 'App preferences',
                        onTap: () {
                          Navigator.push(context, FadePageRoute(child: const SettingsScreen()));
                        },
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // THE FIX 2: Update the header to accept the user's name.
  Widget _buildProfileHeader(String? imagePath, String userName) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                backgroundImage: imagePath != null ? FileImage(File(imagePath)) : null,
                child: imagePath == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white70)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Color(0xFF2D1458)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Use the dynamic user name
          Text(
            'Hi $userName!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
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
