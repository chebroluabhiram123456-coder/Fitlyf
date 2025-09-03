import 'package:fitlyf/models/exercise_model.dart';

class WorkoutSession {
  DateTime date;
  String name;
  List<Exercise> exercises;
  WorkoutSession({required this.date, required this.name, required this.exercises});
}
