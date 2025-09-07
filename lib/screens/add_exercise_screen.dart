import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'dart:math'; // For random ID

class AddExerciseScreen extends StatefulWidget {
  final Exercise? exerciseToEdit;

  const AddExerciseScreen({super.key, this.exerciseToEdit});

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _muscleController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;

  bool get _isEditing => widget.exerciseToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exerciseToEdit?.name ?? '');
    _muscleController = TextEditingController(text: widget.exerciseToEdit?.targetMuscle ?? '');
    _setsController = TextEditingController(text: widget.exerciseToEdit?.sets.toString() ?? '');
    _repsController = TextEditingController(text: widget.exerciseToEdit?.reps.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _muscleController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<WorkoutProvider>(context, listen: false);
      
      if (_isEditing) {
        // Logic for updating an existing exercise
        final updatedExercise = Exercise(
          id: widget.exerciseToEdit!.id,
          name: _nameController.text.trim(),
          targetMuscle: _muscleController.text.trim(),
          sets: int.tryParse(_setsController.text) ?? 0,
          reps: int.tryParse(_repsController.text) ?? 0,
          // Copy other properties like image/video URLs if they exist
        );
        provider.updateExercise(updatedExercise);
      } else {
        // Logic for adding a new exercise
        // *** THIS IS THE FIX: We create the Exercise object first ***
        final newExercise = Exercise(
          id: 'ex${Random().nextInt(1000)}', // Simple random ID
          name: _nameController.text.trim(),
          targetMuscle: _muscleController.text.trim(),
          sets: int.tryParse(_setsController.text) ?? 0,
          reps: int.tryParse(_repsController.text) ?? 0,
        );
        // *** And then we pass it to the provider method ***
        provider.addCustomExercise(newExercise);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Exercise' : 'Add Custom Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExercise,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
              validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            ),
            // Add other form fields for muscle, sets, reps etc.
          ],
        ),
      ),
    );
  }
}
