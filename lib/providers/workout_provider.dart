import 'package:flutter/material.dart';
import 'package:fitlyf/models/exercise_model.dart';
import 'package:fitlyf/models/workout_session.dart';

class WorkoutProvider with ChangeNotifier {
  final List<Exercise> _masterExerciseList = [];
  final Map<DateTime, WorkoutSession> _dailyWorkouts = {};

  // NEW: Centralized weekly plan (Key: 1=Monday, 7=Sunday)
  final Map<int, List<String>> _weeklyPlan = {
    1: ['Chest', 'Triceps'], // Monday
    2: ['Back', 'Biceps'],    // Tuesday
    3: ['Legs', 'Shoulders'], // Wednesday
    4: ['Rest Day'],          // Thursday
    5: ['Full Body'],         // Friday
    6: ['Cardio'],            // Saturday
    7: ['Rest Day'],          // Sunday
  };

  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  late WorkoutSession _selectedWorkout;

  WorkoutProvider() {
    _loadWorkoutForDate(_selectedDate);
  }

  // --- GETTERS ---
  DateTime get selectedDate => _selectedDate;
  WorkoutSession get selectedWorkout => _selectedWorkout;
  List<Exercise> get masterExerciseList => _masterExerciseList;
  Map<int, List<String>> get weeklyPlan => _weeklyPlan;

  // --- METHODS ---
  void _loadWorkoutForDate(DateTime date) {
    // Check if a specific workout has already been generated for this date
    if (_dailyWorkouts.containsKey(date)) {
      _selectedWorkout = _dailyWorkouts[date]!;
      return;
    }

    // Otherwise, create a workout based on the weekly plan
    final dayOfWeek = date.weekday;
    final musclesToTarget = _weeklyPlan[dayOfWeek] ?? ['Rest Day'];

    if (musclesToTarget.contains('Rest Day')) {
      _selectedWorkout = WorkoutSession(date: date, name: 'Rest Day', exercises: []);
    } else {
      final exercisesForMuscle = _masterExerciseList
          .where((ex) => musclesToTarget.contains(ex.muscleGroup))
          .toList();

      _selectedWorkout = WorkoutSession(
        date: date,
        name: musclesToTarget.join(' & '),
        exercises: exercisesForMuscle,
      );
    }
  }

  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    _loadWorkoutForDate(newDate);
    notifyListeners();
  }
  
  // NEW: Method to update the weekly plan
  void updateWeeklyPlan(int weekday, List<String> muscles) {
    if (muscles.isEmpty) {
      _weeklyPlan[weekday] = ['Rest Day'];
    } else {
      _weeklyPlan[weekday] = muscles;
    }
    // Reload the current day's workout if it was the one that changed
    if (_selectedDate.weekday == weekday) {
      _loadWorkoutForDate(_selectedDate);
    }
    notifyListeners();
  }

  void addExerciseToMasterList(Exercise exercise) {
    _masterExerciseList.add(exercise);
    notifyListeners();
  }

  void toggleExerciseCompletion(String exerciseId) {
    final exercise = _selectedWorkout.exercises.firstWhere((ex) => ex.id == exerciseId);
    exercise.isCompleted = !exercise.isCompleted;
    notifyListeners();
  }
}
