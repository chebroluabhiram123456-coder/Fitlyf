// lib/models/exercise_model.dart
class Exercise {
  final String id;
  final String name;
  final String muscleGroup; // The new required field
  bool isCompleted;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup, // Added to the constructor
    this.isCompleted = false,
  });
}
