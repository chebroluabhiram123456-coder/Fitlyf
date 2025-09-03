import 'package:flutter/material.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/workout_session.dart';

class WorkoutProvider with ChangeNotifier {
  WorkoutSession _todaysWorkout = WorkoutSession(
    date: DateTime.now(),
    name: 'Chest, Shoulders, Core',
    exercises: [
      Exercise(id: 'ex1', name: 'Barbell Incline Bench Press', weight: 45),
      Exercise(id: 'ex2', name: 'Barbell Push Press', weight: 30),
      Exercise(id: 'ex3', name: 'Cable Pushdowns', weight: 25),
      Exercise(id: 'ex4', name: 'Machine Triceps Dips', weight: 27.5),
    ],
  );

  WorkoutSession get todaysWorkout => _todaysWorkout;
}
