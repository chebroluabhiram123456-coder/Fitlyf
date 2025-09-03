import 'dart.io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package.provider/provider.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedMuscleGroup;
  File? _imageFile;
  File? _videoFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> _muscleGroups = [
    'Chest', 'Bicep', 'Tricep', 'Shoulder', 'Back', 'Legs', 'Abs', 'Forearms'
  ];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _videoFile = File(pickedFile.path));
  }

  void _saveExercise() {
    if (_nameController.text.isNotEmpty && _selectedMuscleGroup != null) {
      final newExercise = Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        muscleGroup: _selectedMuscleGroup!,
        description: _descriptionController.text,
        imagePath: _imageFile?.path,
        videoPath: _videoFile?.path,
      );
      // Use the provider to add the new exercise to the master list
      Provider.of<WorkoutProvider>(context, listen: false).addExerciseToMasterList(newExercise);
      Navigator.pop(context); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // ... (Gradient decoration remains the same)
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Add New Exercise'),
          // ... (AppBar style remains the same)
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_nameController, 'Exercise Name'),
              const SizedBox(height: 20),
              _buildMuscleGroupSelector(),
              const SizedBox(height: 20),
              _buildTextField(_descriptionController, 'Description (Optional)'),
              const SizedBox(height: 30),
              FrostedGlassCard(
                child: Column(
                  children: [
                    _buildPickerButton(icon: Icons.image, label: 'Add Image', onPressed: _pickImage, filePath: _imageFile?.path),
                    const SizedBox(height: 20),
                    _buildPickerButton(icon: Icons.videocam, label: 'Add Video', onPressed: _pickVideo, filePath: _videoFile?.path),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveExercise,
                // ... (Button style remains the same)
                child: const Text('Save Exercise to Library'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleGroupSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedMuscleGroup,
      hint: const Text('Select Muscle Group', style: TextStyle(color: Colors.white70)),
      dropdownColor: const Color(0xFF2D1458),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        // ... (InputDecoration style remains the same)
      ),
      items: _muscleGroups.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedMuscleGroup = newValue;
        });
      },
    );
  }
  
  // ... (_buildTextField and _buildPickerButton widgets remain the same)
}
