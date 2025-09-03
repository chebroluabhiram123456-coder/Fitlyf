import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitflow/models/exercise_model.dart';
import 'package:fitflow/providers/workout_provider.dart';
import 'package:fitflow/widgets/gradient_background.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _muscleController = TextEditingController();

  File? _imageFile;
  File? _videoFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      final newExercise = Exercise(
        id: DateTime.now().toIso8601String(), // Unique ID
        name: _nameController.text,
        targetMuscle: _muscleController.text,
        imagePath: _imageFile?.path,
        videoPath: _videoFile?.path,
      );
      Provider.of<WorkoutProvider>(context, listen: false).addCustomExercise(newExercise);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Add Custom Exercise', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Exercise Name', 'e.g., Incline Dumbbell Press'),
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _muscleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Target Muscle', 'e.g., Upper Chest'),
                  validator: (value) => value!.isEmpty ? 'Please enter a target muscle' : null,
                ),
                const SizedBox(height: 30),
                
                // Image and Video Pickers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPickerButton(
                      icon: Icons.image,
                      label: 'Add Image',
                      onPressed: _pickImage,
                      filePath: _imageFile?.path,
                    ),
                    _buildPickerButton(
                      icon: Icons.videocam,
                      label: 'Add Video',
                      onPressed: _pickVideo,
                      filePath: _videoFile?.path,
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveExercise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'Save Exercise',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPickerButton({required IconData icon, required String label, required VoidCallback onPressed, String? filePath}) {
    bool isSelected = filePath != null;
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: isSelected ? Colors.green : Colors.black.withOpacity(0.4),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8),
        Text(isSelected ? 'File Added!' : label, style: TextStyle(color: isSelected ? Colors.cyanAccent : Colors.white70)),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white54),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.cyanAccent),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}
