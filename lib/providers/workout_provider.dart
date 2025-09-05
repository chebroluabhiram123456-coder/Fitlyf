import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';

class WorkoutProvider with ChangeNotifier {
  final List<Workout> _workouts = [
    Workout(
      id: 'w1',
      name: 'Full Body Workout',
      description: 'A comprehensive workout targeting all major muscle groups.',
      exercises: [
        // FIXES APPLIED BELOW
        Exercise(
          id: 'ex1',
          name: 'Barbell Incline Bench Press',
          targetMuscle: 'Chest', // Added this line
        ),
        Exercise(
          id: 'ex2',
          name: 'Barbell Push Press',
          targetMuscle: 'Shoulders', // Added this line
        ),
      ],
    ),
    Workout(
      id: 'w2',
      name: 'Leg Day',
      description: 'A workout focused on strengthening your lower body.',
      exercises: [
        // FIXES APPLIED BELOW
        Exercise(
          id: 'ex3',
          name: 'Squats',
          targetMuscle: 'Legs', // Added this line
        ),
        Exercise(
          id: 'ex4',
          name: 'Deadlifts',
          targetMuscle: 'Back and Hamstrings', // Added this line
        ),
      ],
    ),
  ];

  List<Workout> get workouts {
    return [..._workouts];
  }

  Workout findById(String id) {
    return _workouts.firstWhere((workout) => workout.id == id);
  }

  void addWorkout(Workout workout) {
    _workouts.add(workout);
    notifyListeners();
  }
}
