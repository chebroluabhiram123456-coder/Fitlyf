// lib/providers/workout_provider.dart
import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/workout_session.dart'; // CORRECTED IMPORT

class WorkoutProvider with ChangeNotifier {
  // DATA
  DateTime _selectedDate = DateTime.now();

  final Map<DateTime, double> _weightHistory = {
    DateTime.now().subtract(const Duration(days: 10)): 78.5,
    DateTime.now().subtract(const Duration(days: 7)): 78.0,
    DateTime.now().subtract(const Duration(days: 1)): 77.2,
  };

  final List<Exercise> _masterExerciseList = [
    Exercise(id: 'ex01', name: 'Push-ups'),
    Exercise(id: 'ex02', name: 'Squats'),
    Exercise(id: 'ex03', name: 'Pull-ups'),
    Exercise(id: 'ex04', name: 'Plank'),
    Exercise(id: 'ex05', name: 'Lunges'),
    Exercise(id: 'ex06', name: 'Bench Press'),
    Exercise(id: 'ex07', name: 'Deadlift'),
  ];

  Map<int, String?> _weeklyPlan = {
    0: 'wk01', // Monday -> Upper Body
    1: null, // Tuesday -> Rest
    2: 'wk02', // Wednesday -> Lower Body
    3: null, // Thursday -> Rest
    4: 'wk03', // Friday -> Full Body
    5: null, // Saturday -> Rest
    6: null, // Sunday -> Rest
  };

  final List<WorkoutSession> _masterWorkoutList = [ // CORRECTED TYPE
    WorkoutSession( // CORRECTED TYPE
      id: 'wk01',
      name: 'Upper Body Focus',
      exercises: [
        Exercise(id: 'ex01', name: 'Push-ups'),
        Exercise(id: 'ex03', name: 'Pull-ups'),
        Exercise(id: 'ex06', name: 'Bench Press'),
      ],
    ),
    WorkoutSession( // CORRECTED TYPE
      id: 'wk02',
      name: 'Lower Body Strength',
      exercises: [
        Exercise(id: 'ex02', name: 'Squats'),
        Exercise(id: 'ex05', name: 'Lunges'),
        Exercise(id: 'ex07', name: 'Deadlift'),
      ],
    ),
     WorkoutSession( // CORRECTED TYPE
      id: 'wk03',
      name: 'Full Body Core',
      exercises: [
        Exercise(id: 'ex01', name: 'Push-ups'),
        Exercise(id: 'ex02', name: 'Squats'),
        Exercise(id: 'ex04', name: 'Plank'),
      ],
    ),
  ];

  // GETTERS
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, double> get weightHistory => _weightHistory;
  List<Exercise> get masterExerciseList => _masterExerciseList;
  Map<int, String?> get weeklyPlan => _weeklyPlan;

  WorkoutSession? get selectedWorkout { // CORRECTED TYPE
    final dayOfWeek = _selectedDate.weekday - 1;
    final workoutId = _weeklyPlan[dayOfWeek];
    if (workoutId == null) return null;
    return _masterWorkoutList.firstWhere((w) => w.id == workoutId);
  }

  // METHODS
  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }

  void toggleExerciseCompletion(String exerciseId) {
    final workout = selectedWorkout;
    if (workout != null) {
      final exercise = workout.exercises.firstWhere((ex) => ex.id == exerciseId);
      exercise.isCompleted = !exercise.isCompleted;
      notifyListeners();
    }
  }
  
  void addExerciseToMasterList(Exercise newExercise) {
    _masterExerciseList.add(newExercise);
    notifyListeners();
  }
  
  void updateWeeklyPlan(int dayIndex, String? workoutId) {
      _weeklyPlan[dayIndex] = workoutId;
      notifyListeners();
  }
}
