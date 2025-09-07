import 'package:fitlyf/models/exercise_model.dart';

class Workout {
  final String id;
  final String name;
  final List<Exercise> exercises;
  // Add any other properties you have for a workout here

  Workout({
    required this.id,
    required this.name,
    required this.exercises,
  });

  // *** THIS METHOD IS NEEDED FOR THE REORDERING FEATURE ***
  // It creates a new Workout instance with potentially updated values.
  Workout copyWith({
    String? id,
    String? name,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
    );
  }
}
