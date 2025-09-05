import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Needed for date formatting

// ----- THE FIX: These imports were missing -----
import '../models/workout_model.dart'; 
import '../models/exercise_model.dart';

class WorkoutProvider with ChangeNotifier {
  // --- DATA ---
  final List<Workout> _workouts = [
    Workout(
      id: 'w1', name: 'Full Body Workout', description: 'A comprehensive workout targeting all major muscle groups.',
      exercises: [
        Exercise(id: 'ex1', name: 'Barbell Incline Bench Press', targetMuscle: 'Chest', sets: 4, reps: 8),
        Exercise(id: 'ex2', name: 'Barbell Push Press', targetMuscle: 'Shoulders', sets: 3, reps: 10),
      ],
    ),
    Workout(
      id: 'w2', name: 'Leg Day', description: 'A workout focused on strengthening your lower body.',
      exercises: [
        Exercise(id: 'ex3', name: 'Squats', targetMuscle: 'Legs', sets: 4, reps: 6),
        Exercise(id: 'ex4', name: 'Deadlifts', targetMuscle: 'Back and Hamstrings', sets: 3, reps: 5),
      ],
    ),
  ];

  Map<String, String> _weeklyPlan = {
    'Monday': 'Full Body Workout', 'Tuesday': 'Rest', 'Wednesday': 'Leg Day',
    'Thursday': 'Rest', 'Friday': 'Full Body Workout', 'Saturday': 'Rest', 'Sunday': 'Rest',
  };

  Map<DateTime, double> _weightHistory = {
    DateTime.now().subtract(const Duration(days: 7)): 75.0,
    DateTime.now().subtract(const Duration(days: 3)): 74.5,
    DateTime.now(): 74.8,
  };

  DateTime _selectedDate = DateTime.now();

  // --- GETTERS AND METHODS ---

  List<Workout> get workouts => [..._workouts];
  Map<String, String> get weeklyPlan => {..._weeklyPlan};
  Map<DateTime, double> get weightHistory => {..._weightHistory};
  DateTime get selectedDate => _selectedDate;

  // This getter fixes the final error for the home screen
  Workout? get selectedWorkout {
    final dayOfWeek = DateFormat('EEEE').format(_selectedDate);
    final workoutName = _weeklyPlan[dayOfWeek];
    if (workoutName == null || workoutName == 'Rest') {
      return null;
    }
    return _workouts.firstWhere((w) => w.name == workoutName);
  }

  double get latestWeight {
    if (_weightHistory.isEmpty) return 0.0;
    return _weightHistory.entries.last.value;
  }

  List<Exercise> get allExercises {
    return _workouts.expand((workout) => workout.exercises).toList();
  }
  
  void logUserWeight(double weight) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _weightHistory[today] = weight;
    notifyListeners();
  }

  void changeSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void updateWeeklyPlan(String day, String workoutName) {
    _weeklyPlan[day] = workoutName;
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
