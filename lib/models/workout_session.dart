// lib/models/workout_session.dart

import 'package:fitlyf/models/exercise_model.dart';

class WorkoutSession {
  String id; // Added this ID
  DateTime date;
  String name;
  List<Exercise> exercises;

  WorkoutSession({
    required this.id, // Made it required
    required this.date,
    required this.name,
    required this.exercises,
  });
}
