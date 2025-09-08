import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:fitlyf/screens/exercise_library_screen.dart';
// *** FIX: Corrected the import to point to the correct history screen ***
import 'package:fitlyf/screens/workout_history_screen.dart'; 
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // --- Logic for Image Picking ---
  Future<void> _pickImage() async {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final ImagePicker picker = ImagePicker();
    // Pick an image from the gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // If an image is picked, update the provider with the new image path
      provider.updateProfilePicture(image.path);
    }
  }

  // --- Logic for Editing Name ---
  void _showEditNameDialog(BuildContext context, WorkoutProvider provider) {
    final TextEditingController controller = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3E246E),
          title: const Text('Edit Your Name', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  provider.updateUserName(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use a Consumer here so the UI rebuilds when the user's name or picture changes
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A148C), Color(0xFF2D1458), Color(0xFF1A0E38)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // *** NEW: Interactive Profile Header ***
                _buildProfileHeader(context, workoutProvider),
                const SizedBox(height: 30),

                // Your original, beautiful menu items are preserved below
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
                _buildProfileMenuItem(
                  context: context,
                  icon: Icons.history,
                  title: 'Workout History', // Corrected title
                  subtitle: 'See your past workouts',
                  onTap: () {
                    // *** FIX: Corrected navigation to the correct history screen ***
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WorkoutHistoryScreen()),
                    );
                  },
                ),
                _buildProfileMenuItem(
                  context: context,
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () {
                    // TODO: Navigate to a real settings screen
                  },
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    // TODO: Implement logout functionality using Firebase Auth
                  },
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- NEW Widget for the Profile Header ---
  Widget _buildProfileHeader(BuildContext context, WorkoutProvider provider) {
    return Row(
      children: [
        // The tappable profile picture
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF4A337B),
            backgroundImage: provider.profileImagePath != null 
              ? FileImage(File(provider.profileImagePath!)) 
              : null,
            child: provider.profileImagePath == null
              ? const Icon(Icons.person, size: 40, color: Colors.white70)
              : null,
          ),
        ),
        const SizedBox(width: 20),
        // The tappable name
        Expanded(
          child: GestureDetector(
            onTap: () => _showEditNameDialog(context, provider),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    provider.userName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit, color: Colors.white54, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Your original _buildProfileMenuItem method - perfect as it was.
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
