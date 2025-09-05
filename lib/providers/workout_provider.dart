import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';

class WorkoutProvider with ChangeNotifier {
  // --- DATA ---
  final List<Workout> _workouts = [
    Workout(
      id: 'w1',
      name: 'Full Body Workout',
      description: 'A comprehensive workout targeting all major muscle groups.',
      exercises: [
        Exercise(id: 'ex1', name: 'Barbell Incline Bench Press', targetMuscle: 'Chest'),
        Exercise(id: 'ex2', name: 'Barbell Push Press', targetMuscle: 'Shoulders'),
      ],
    ),
    Workout(
      id: 'w2',
      name: 'Leg Day',
      description: 'A workout focused on strengthening your lower body.',
      exercises: [
        Exercise(id: 'ex3', name: 'Squats', targetMuscle: 'Legs'),
        Exercise(id: 'ex4', name: 'Deadlifts', targetMuscle: 'Back and Hamstrings'),
      ],
    ),
  ];

  Map<String, String> _weeklyPlan = {
    'Monday': 'Full Body Workout',
    'Tuesday': 'Rest',
    'Wednesday': 'Leg Day',
    'Thursday': 'Rest',
    'Friday': 'Full Body Workout',
    'Saturday': 'Rest',
    'Sunday': 'Rest',
  };

  Map<DateTime, double> _weightHistory = {
    DateTime.now().subtract(const Duration(days: 7)): 75.0,
    DateTime.now().subtract(const Duration(days: 3)): 74.5,
    DateTime.now(): 74.8,
  };

  // --- GETTERS AND METHODS (This section fixes all the errors) ---

  List<Workout> get workouts => [..._workouts];
  Map<String, String> get weeklyPlan => {..._weeklyPlan};
  Map<DateTime, double> get weightHistory => {..._weightHistory};

  List<Exercise> get allExercises {
    return _workouts.expand((workout) => workout.exercises).toList();
  }

  void updateWeeklyPlan(String day, String workoutName) {
    _weeklyPlan[day] = workoutName;
    notifyListeners();
  }

  void addWeight(double weight) {
    // Using a key with date only to avoid multiple entries on the same day
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _weightHistory[today] = weight;
    notifyListeners();
  }

  Workout findById(String id) {
    return _workouts.firstWhere((workout) => workout.id == id);
  }

  void addWorkout(Workout workout) {
    _workouts.add(workout);
    notifyListeners();
  }
}
