// lib/models/workout_session.dart
import 'exercise_model.dart';

class WorkoutSession {
  // FIX: Added the required 'id' field.
  final String id;
  final String name;
  final DateTime? date; // Made date optional for template workouts
  final List<Exercise> exercises;

  WorkoutSession({
    required this.id, // FIX: Added 'id' to the constructor.
    required this.name,
    this.date,
    required this.exercises,
  });
}
