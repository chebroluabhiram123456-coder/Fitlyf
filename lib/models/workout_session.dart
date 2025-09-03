import 'package:fitflow/models/exercise_model.dart';

class WorkoutSession {
  DateTime date;
  String muscleTarget;
  List<Exercise> exercises;

  WorkoutSession({
    required this.date,
    required this.muscleTarget,
    required this.exercises,
  });
}
