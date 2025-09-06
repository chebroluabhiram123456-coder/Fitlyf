import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitlyf/models/exercise_model.dart';

class AddExerciseScreen extends StatefulWidget {
  final Exercise? exerciseToEdit;
  const AddExerciseScreen({Key? key, this.exerciseToEdit}) : super(key: key);

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  String? _selectedMuscleGroup;
  File? _imageFile;
  File? _videoFile;
  final ImagePicker _picker = ImagePicker();
  bool get _isEditMode => widget.exerciseToEdit != null;
  bool get _canDelete => _isEditMode;

  final List<String> _muscleGroups = [
    'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Legs', 'Abs', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final ex = widget.exerciseToEdit!;
      _nameController.text = ex.name;
      _descController.text = ex.description ?? '';
      _setsController.text = ex.sets.toString();
      _repsController.text = ex.reps.toString();
      _selectedMuscleGroup = ex.targetMuscle;
      if (ex.imageUrl != null) _imageFile = File(ex.imageUrl!);
      if (ex.videoUrl != null) _videoFile = File(ex.videoUrl!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(bool isVideo) async {
    try {
      final XFile? pickedFile = isVideo
          ? await _picker.pickVideo(source: ImageSource.gallery)
          : await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null && mounted) {
        setState(() {
          if (isVideo) { _videoFile = File(pickedFile.path); }
          else { _imageFile = File(pickedFile.path); }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick media. Please check app permissions. Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  // THE FIX: This function now provides feedback if validation fails.
  void _saveForm() {
    final bool isValid = _formKey.currentState!.validate();

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Stop the function here
    }

    final provider = Provider.of<WorkoutProvider>(context, listen: false);

    if (_isEditMode) {
      final updatedExercise = Exercise(
        id: widget.exerciseToEdit!.id, name: _nameController.text,
        description: _descController.text, targetMuscle: _selectedMuscleGroup!,
        sets: int.parse(_setsController.text), reps: int.parse(_repsController.text),
        imageUrl: _imageFile?.path, videoUrl: _videoFile?.path,
        isCompleted: widget.exerciseToEdit!.isCompleted,
      );
      provider.updateExercise(updatedExercise);
    } else {
      provider.addCustomExercise(
        name: _nameController.text, description: _descController.text,
        targetMuscle: _selectedMuscleGroup!, sets: int.parse(_setsController.text),
        reps: int.parse(_repsController.text), imageUrl: _imageFile?.path, videoUrl: _videoFile?.path,
      );
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_nameController.text} has been saved!'), backgroundColor: Colors.green),
    );
    
    Navigator.of(context).pop();
  }

  void _showDeleteConfirmation() {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final exercise = widget.exerciseToEdit!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF3E246E),
        title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${exercise.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              provider.deleteExercise(exercise.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${exercise.name} deleted.'), backgroundColor: Colors.red),
              );
            },
          ),
        ],
      ),
    );
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Exercise' : 'Create New Exercise'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [ if (_canDelete) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: _showDeleteConfirmation) ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: FrostedGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextFormField(controller: _nameController, labelText: 'Exercise Name', hintText: 'e.g., Bicep Curls'),
                  const SizedBox(height: 20),
                  _buildTextFormField(controller: _descController, labelText: 'Description (Optional)', hintText: 'e.g., Focus on slow, controlled movement.', maxLines: 3),
                  const SizedBox(height: 20),
                  _buildDropdown(),
                  const SizedBox(height: 20),
                  Row(children: [
                      Expanded(child: _buildTextFormField(controller: _setsController, labelText: 'Sets', hintText: 'e.g., 3', keyboardType: TextInputType.number)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildTextFormField(controller: _repsController, labelText: 'Reps', hintText: 'e.g., 12', keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 20),
                  _buildMediaPicker(),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, foregroundColor: const Color(0xFF2D1458),
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
  
  // ... All other helper methods are unchanged and correct ...
  Widget _buildMediaPicker() { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ if (_imageFile != null) ...[ const Text("Image Preview:", style: TextStyle(color: Colors.white70)), const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover)), const SizedBox(height: 20)], Row(children: [ Expanded(child: _buildPickerButton(icon: Icons.image_outlined, label: "Add Image", onTap: () => _pickMedia(false))), const SizedBox(width: 20), Expanded(child: _buildPickerButton(icon: Icons.videocam_outlined, label: "Add Video", onTap: () => _pickMedia(true))) ]), if (_videoFile != null) Padding(padding: const EdgeInsets.only(top: 10.0), child: Text('Video selected: ${_videoFile!.path.split('/').last}', style: const TextStyle(color: Colors.greenAccent), overflow: TextOverflow.ellipsis)) ]); }
  Widget _buildPickerButton({required IconData icon, required String label, required VoidCallback onTap}) { return Material(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15.0), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15.0), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(icon, size: 20), const SizedBox(width: 8), Text(label) ])))); }
  Widget _buildDropdown() { return DropdownButtonFormField<String>(value: _selectedMuscleGroup, decoration: InputDecoration(labelText: 'Target Muscle', labelStyle: const TextStyle(color: Colors.white70), filled: true, fillColor: Colors.white.withOpacity(0.2), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none)), dropdownColor: const Color(0xFF3E246E), items: _muscleGroups.map((String muscle) { return DropdownMenuItem<String>(value: muscle, child: Text(muscle)); }).toList(), onChanged: (newValue) { setState(() { _selectedMuscleGroup = newValue; }); }, validator: (value) => value == null ? 'Please select a muscle group' : null); }
  Widget _buildTextFormField({ required TextEditingController controller, required String labelText, required String hintText, TextInputType keyboardType = TextInputType.text, int maxLines = 1, }) { return TextFormField(controller: controller, maxLines: maxLines, decoration: InputDecoration(labelText: labelText, hintText: hintText, labelStyle: const TextStyle(color: Colors.white70), hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: Colors.white.withOpacity(0.2), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide.none)), keyboardType: keyboardType, validator: (value) { if (labelText != 'Description (Optional)' && (value == null || value.isEmpty)) { return 'This field cannot be empty'; } return null; }); }
}
