import 'dart:io'; // Needed for file operations
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:image_picker/image_picker.dart'; // Import the new package

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({Key? key}) : super(key: key);

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  String? _selectedMuscleGroup;
  
  // State variables to hold the selected files
  File? _imageFile;
  File? _videoFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> _muscleGroups = [
    'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Legs', 'Abs', 'Cardio', 'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Function to pick a video from the gallery
  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      Provider.of<WorkoutProvider>(context, listen: false).addCustomExercise(
        name: _nameController.text,
        targetMuscle: _selectedMuscleGroup!,
        sets: int.parse(_setsController.text),
        reps: int.parse(_repsController.text),
        // Pass the file paths to the provider
        imageUrl: _imageFile?.path,
        videoUrl: _videoFile?.path,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} has been created!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // THE FIX: Add the gradient background to match the rest of the app
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
          title: const Text('Create New Exercise'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: FrostedGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextFormField(
                    controller: _nameController,
                    labelText: 'Exercise Name',
                    hintText: 'e.g., Bicep Curls',
                  ),
                  const SizedBox(height: 20),
                  _buildDropdown(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextFormField(
                          controller: _setsController,
                          labelText: 'Sets',
                          hintText: 'e.g., 3',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildTextFormField(
                          controller: _repsController,
                          labelText: 'Reps',
                          hintText: 'e.g., 12',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // THE FIX: New section for image/video upload
                  _buildMediaPicker(),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2D1458),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Save Exercise'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imageFile != null) ...[
          const Text("Image Preview:", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 20),
        ],
        Row(
          children: [
            Expanded(child: _buildPickerButton(icon: Icons.image_outlined, label: "Add Image", onTap: _pickImage)),
            const SizedBox(width: 20),
            Expanded(child: _buildPickerButton(icon: Icons.videocam_outlined, label: "Add Video", onTap: _pickVideo)),
          ],
        ),
        if (_videoFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text('Video selected: ${_videoFile!.path.split('/').last}', style: const TextStyle(color: Colors.greenAccent), overflow: TextOverflow.ellipsis,),
          ),
      ],
    );
  }

  Widget _buildPickerButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedMuscleGroup,
      decoration: InputDecoration(
        labelText: 'Target Muscle',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: const Color(0xFF3E246E),
      items: _muscleGroups.map((String muscle) {
        return DropdownMenuItem<String>(
          value: muscle,
          child: Text(muscle),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedMuscleGroup = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a muscle group' : null,
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }
}
