import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';

enum WorkoutStatus { Completed, Skipped, Scheduled, Rest, Future }

class WorkoutProvider with ChangeNotifier {
  String? _profileImagePath;
  String _userName = "User";
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, double> _weightHistory = { /* ... */ };
  
  // THE FIX 1: This now stores a detailed snapshot of each completed workout.
  Map<DateTime, Workout> _workoutLog = {
    // Add a sample completed workout for demonstration
    DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 1))): Workout(
      id: 'logged_w2',
      name: 'Legs & Shoulders',
      exercises: [
        Exercise(id: 'ex3', name: 'Squats', targetMuscle: 'Legs', sets: 5, reps: 5, isCompleted: true),
        Exercise(id: 'ex4', name: 'Barbell Push Press', targetMuscle: 'Shoulders', sets: 3, reps: 10, isCompleted: true),
      ]
    ),
  };

  final List<Workout> _workouts = [ /* ... */ ];
  final List<Exercise> _customExercises = [];
  Map<String, List<String>> _weeklyPlan = { /* ... */ };
  final List<String> availableMuscleGroups = [ /* ... */ ];

  // --- Getters ---
  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, double> get weightHistory => _weightHistory;
  Map<String, List<String>> get weeklyPlan => _weeklyPlan;
  Map<DateTime, Workout> get workoutLog => _workoutLog;

  // ... other getters are unchanged ...
  double get latestWeight {
    if (_weightHistory.isEmpty) return 0.0;
    final sortedDates = _weightHistory.keys.toList()...sort((a, b) => b.compareTo(a));
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
    final dayOfWeek = _selectedDate.weekday;
    final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][dayOfWeek - 1];
    final targetMuscles = _weeklyPlan[dayName];
    if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) return null;
    final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList();
    return Workout(
      id: 'day_${dayName.toLowerCase()}',
      name: targetMuscles.join(' & '),
      exercises: exercisesForDay,
    );
  }
  List<Exercise> get allExercises {
    return [..._workouts.expand((workout) => workout.exercises), ..._customExercises];
  }

  // --- Methods ---
  
  WorkoutStatus getWorkoutStatusForDate(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final dateOnly = DateUtils.dateOnly(date);

    if (dateOnly.isAfter(today)) return WorkoutStatus.Future;
    // THE FIX 2: Check the new workout log instead of the old Set.
    if (_workoutLog.containsKey(dateOnly)) return WorkoutStatus.Completed;

    final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][dateOnly.weekday - 1];
    final plan = _weeklyPlan[dayName];
    if (plan == null || plan.contains('Rest')) return WorkoutStatus.Rest;
    
    return WorkoutStatus.Skipped;
  }
  
  // THE FIX 3: This function now saves the entire workout object.
  void logWorkout(DateTime date, Workout workout) {
    _workoutLog[DateUtils.dateOnly(date)] = workout;
    notifyListeners();
  }
  
  // THE FIX 4: New function to delete a logged workout.
  void deleteLoggedWorkout(DateTime date) {
    _workoutLog.remove(DateUtils.dateOnly(date));
    notifyListeners();
  }
  
  // ... all other methods are unchanged ...
  void markAllExercisesAsComplete(List<Exercise> exercises) { for (var exercise in exercises) { try { final masterExercise = allExercises.firstWhere((e) => e.id == exercise.id); masterExercise.isCompleted = true; } catch (e) { /* Ignore */ } } notifyListeners(); }
  void deleteExercise(String exerciseId) { _customExercises.removeWhere((ex) => ex.id == exerciseId); for (var workout in _workouts) { workout.exercises.removeWhere((ex) => ex.id == exerciseId); } notifyListeners(); }
  void updateExercise(Exercise updatedExercise) { int index = _customExercises.indexWhere((ex) => ex.id == updatedExercise.id); if (index != -1) { _customExercises[index] = updatedExercise; notifyListeners(); return; } for (var workout in _workouts) { index = workout.exercises.indexWhere((ex) => ex.id == updatedExercise.id); if (index != -1) { workout.exercises[index] = updatedExercise; notifyListeners(); return; } } }
  void addCustomExercise({ required String name, required String targetMuscle, required int sets, required int reps, String? imageUrl, String? videoUrl }) { final newExercise = Exercise( id: 'custom_${DateTime.now().toIso8601String()}', name: name, targetMuscle: targetMuscle, sets: sets, reps: reps, imageUrl: imageUrl, videoUrl: videoUrl, ); _customExercises.add(newExercise); notifyListeners(); }
  void logUserWeight(double weight) { _weightHistory.removeWhere((key, value) => DateUtils.isSameDay(key, _selectedDate)); _weightHistory[_selectedDate] = weight; notifyListeners(); }
  void changeSelectedDate(DateTime newDate) { _selectedDate = newDate; notifyListeners(); }
  void updateWeeklyPlan(String day, List<String> muscleGroups) { _weeklyPlan[day] = muscleGroups; notifyListeners(); }
  void toggleExerciseCompletion(String exerciseId, bool isCompleted) { final exercise = allExercises.firstWhere((ex) => ex.id == exerciseId); exercise.isCompleted = isCompleted; notifyListeners(); }
  void updateProfilePicture(String imagePath) { _profileImagePath = imagePath; notifyListeners(); }
}
