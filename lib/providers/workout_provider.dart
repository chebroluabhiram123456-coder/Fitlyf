// THE FIX: Add all missing import statements.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';

enum WorkoutStatus { Completed, Skipped, Scheduled, Rest, Future }

// THE FIX: Add 'with ChangeNotifier' to the class definition.
class WorkoutProvider with ChangeNotifier {
  String? _profileImagePath;
  String _userName = "User";
  DateTime _selectedDate = DateTime.now();
  final Map<DateTime, double> _weightHistory = {
    DateTime.now().subtract(const Duration(days: 3)): 75.0,
    DateTime.now().subtract(const Duration(days: 2)): 75.5,
    DateTime.now(): 76.0,
  };
  final Map<DateTime, Workout> _workoutLog = {
    DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 1))): Workout(
      id: 'logged_w2', name: 'Legs & Shoulders', exercises: [
        Exercise(id: 'ex3', name: 'Squats', targetMuscle: 'Legs', sets: 5, reps: 5, isCompleted: true),
        Exercise(id: 'ex4', name: 'Barbell Push Press', targetMuscle: 'Shoulders', sets: 3, reps: 10, isCompleted: true),
      ]
    ),
  };

  final List<Workout> _workouts = [
    Workout( id: 'w1', name: 'Full Body A', exercises: [
        Exercise(id: 'ex1', name: 'Barbell Incline Bench Press', targetMuscle: 'Chest', sets: 4, reps: 8, description: 'An upper-body strength exercise that targets the pectoral muscles, deltoids, and triceps.'),
        Exercise(id: 'ex2', name: 'Barbell Push Press', targetMuscle: 'Shoulders', sets: 3, reps: 10, description: 'A powerful overhead press variation that utilizes leg drive to lift heavier weights.'),
    ]),
    Workout( id: 'w2', name: 'Full Body B', exercises: [
        Exercise(id: 'ex3', name: 'Squats', targetMuscle: 'Legs', sets: 5, reps: 5, description: 'A fundamental lower-body exercise that strengthens the quadriceps, hamstrings, and glutes.'),
        Exercise(id: 'ex4', name: 'Deadlifts', targetMuscle: 'Back', sets: 1, reps: 5, description: 'A compound lift that works the entire posterior chain, including the back, glutes, and hamstrings.'),
    ]),
  ];
  
  final List<Exercise> _customExercises = [];
  Map<String, List<String>> _weeklyPlan = {
    'Monday': ['Chest', 'Biceps'], 'Tuesday': ['Back', 'Triceps'], 'Wednesday': ['Legs', 'Shoulders'],
    'Thursday': ['Rest'], 'Friday': ['Chest', 'Back'], 'Saturday': ['Abs'], 'Sunday': ['Rest'],
  };

  final List<String> availableMuscleGroups = [
    'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Legs', 'Abs', 'Rest'
  ];

  // --- Getters ---
  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, double> get weightHistory => _weightHistory;
  Map<String, List<String>> get weeklyPlan => _weeklyPlan;
  Map<DateTime, Workout> get workoutLog => _workoutLog;

  double get latestWeight {
    if (_weightHistory.isEmpty) return 0.0;
    final sortedDates = _weightHistory.keys.toList()..sort((a, b) => b.compareTo(a));
    return _weightHistory[sortedDates.first]!;
  }
  
  double? get weightForSelectedDate {
    final entry = _weightHistory.entries.firstWhere(
      (entry) => DateUtils.isSameDay(entry.key, _selectedDate),
      orElse: () => MapEntry(DateTime(0), -1.0),
    );
    return entry.value == -1.0 ? null : entry.value;
  }

  Workout? get selectedWorkout {
    final dayName = DateFormat('EEEE').format(_selectedDate);
    final targetMuscles = _weeklyPlan[dayName];
    if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) return null;
    final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList();
    return Workout(id: 'day_${dayName.toLowerCase()}', name: targetMuscles.join(' & '), exercises: exercisesForDay);
  }
  
  Workout? get getTodaysWorkout {
    final dayName = DateFormat('EEEE').format(DateTime.now());
    final targetMuscles = _weeklyPlan[dayName];
    if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) return null;
    final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList();
    return Workout(id: 'today_workout', name: targetMuscles.join(' & '), exercises: exercisesForDay);
  }

  List<Exercise> get allExercises {
    return [..._workouts.expand((workout) => workout.exercises), ..._customExercises];
  }

  // --- Methods ---
  
  WorkoutStatus getWorkoutStatusForDate(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final dateOnly = DateUtils.dateOnly(date);
    if (dateOnly.isAfter(today)) return WorkoutStatus.Future;
    if (_workoutLog.containsKey(dateOnly)) return WorkoutStatus.Completed;
    final dayName = DateFormat('EEEE').format(dateOnly);
    final plan = _weeklyPlan[dayName];
    if (plan == null || plan.contains('Rest')) return WorkoutStatus.Rest;
    return WorkoutStatus.Skipped;
  }
  
  void logWorkout(DateTime date, Workout workout) { _workoutLog[DateUtils.dateOnly(date)] = workout; notifyListeners(); }
  void deleteLoggedWorkout(DateTime date) { _workoutLog.remove(DateUtils.dateOnly(date)); notifyListeners(); }
  void markAllExercisesAsComplete(List<Exercise> exercises) { for (var ex in exercises) { try { allExercises.firstWhere((e) => e.id == ex.id).isCompleted = true; } catch (e) {} } notifyListeners(); }
  void updateWeeklyPlan(String day, List<String> muscleGroups) { _weeklyPlan[day] = muscleGroups; notifyListeners(); }
  void updateUserName(String newName) { _userName = newName; notifyListeners(); }
  void deleteExercise(String exerciseId) { _customExercises.removeWhere((ex) => ex.id == exerciseId); for (var workout in _workouts) { workout.exercises.removeWhere((ex) => ex.id == exerciseId); } notifyListeners(); }
  
  void updateExercise(Exercise updatedExercise) {
    int index = _customExercises.indexWhere((ex) => ex.id == updatedExercise.id);
    if (index != -1) { _customExercises[index] = updatedExercise; }
    else {
      for (var workout in _workouts) {
        index = workout.exercises.indexWhere((ex) => ex.id == updatedExercise.id);
        if (index != -1) { workout.exercises[index] = updatedExercise; break; }
      }
    }
    notifyListeners();
  }
  
  void addCustomExercise({ required String name, required String targetMuscle, String? description, required int sets, required int reps, String? imageUrl, String? videoUrl }) {
    final newExercise = Exercise(
      id: 'custom_${DateTime.now().toIso8601String()}', name: name, targetMuscle: targetMuscle,
      description: description, sets: sets, reps: reps, imageUrl: imageUrl, videoUrl: videoUrl,
    );
    _customExercises.add(newExercise);
    notifyListeners();
  }
  
  void logUserWeight(double weight) { _weightHistory.removeWhere((key, value) => DateUtils.isSameDay(key, _selectedDate)); _weightHistory[_selectedDate] = weight; notifyListeners(); }
  void changeSelectedDate(DateTime newDate) { _selectedDate = newDate; notifyListeners(); }
  void toggleExerciseCompletion(String exerciseId, bool isCompleted) { allExercises.firstWhere((ex) => ex.id == exerciseId).isCompleted = isCompleted; notifyListeners(); }
  void updateProfilePicture(String imagePath) { _profileImagePath = imagePath; notifyListeners(); }
}
