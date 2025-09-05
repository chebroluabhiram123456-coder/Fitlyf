import 'exercise_model.dart';

class Workout {
  final String id;
  final String name;
  final List<Exercise> exercises;

  Workout({
    required this.id,
    required this.name,
    required this.exercises,
  });
}
