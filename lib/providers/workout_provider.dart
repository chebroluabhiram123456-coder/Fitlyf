import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../models/set_log_model.dart';

enum WorkoutStatus { Completed, Skipped, Scheduled, Rest, Future }

class WorkoutProvider with ChangeNotifier {
  String? _profileImagePath;
  String _userName = "User";
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, double> _weightHistory = {};
  Map<DateTime, Workout> _workoutLog = {};
  final List<Exercise> _customExercises = [];
  
  // This is the temporary checklist for the live workout session.
  Set<String> _inProgressExerciseIds = {};

  final List<Workout> _workouts = [ /* ... */ ];
  Map<String, List<String>> _weeklyPlan = { /* ... */ };
  final List<String> availableMuscleGroups = [ /* ... */ ];

  // --- Getters ---
  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, double> get weightHistory => _weightHistory;
  Map<String, List<String>> get weeklyPlan => _weeklyPlan;
  Map<DateTime, Workout> get workoutLog => _workoutLog;

  bool isExerciseInProgressCompleted(String exerciseId) => _inProgressExerciseIds.contains(exerciseId);
  
  // THE FIX 1: This getter is now "session-aware".
  // It creates a temporary workout snapshot with the real-time completion status.
  Workout? get selectedWorkout {
    final dayName = DateFormat('EEEE').format(_selectedDate);
    final targetMuscles = _weeklyPlan[dayName];
    if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) return null;
    
    final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList();
    
    return Workout(
      id: 'day_${dayName.toLowerCase()}',
      name: targetMuscles.join(' & '),
      exercises: exercisesForDay.map((ex) => Exercise(
        id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps,
        description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl,
        isCompleted: _inProgressExerciseIds.contains(ex.id) // Use live session data
      )).toList(),
    );
  }
  
  // THE FIX 2: This getter is also now "session-aware" for the Progress screen.
  Workout? get getTodaysWorkout {
    final dayName = DateFormat('EEEE').format(DateTime.now());
    final targetMuscles = _weeklyPlan[dayName];
    if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) return null;
    
    final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList();
    
    return Workout(
      id: 'today_workout',
      name: targetMuscles.join(' & '),
      exercises: exercisesForDay.map((ex) => Exercise(
        id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps,
        description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl,
        isCompleted: _inProgressExerciseIds.contains(ex.id) // Use live session data
      )).toList(),
    );
  }

  List<Exercise> get allExercises {
    return [..._workouts.expand((workout) => workout.exercises), ..._customExercises];
  }

  // --- Methods ---
  
  void startWorkoutSession() { _inProgressExerciseIds.clear(); notifyListeners(); }

  void toggleInProgressExerciseCompletion(String exerciseId, bool isCompleted) {
    if (isCompleted) { _inProgressExerciseIds.add(exerciseId); }
    else { _inProgressExerciseIds.remove(exerciseId); }
    notifyListeners(); // This is what triggers the sync
  }

  bool areAllExercisesComplete(List<Exercise> exercises) {
    if (exercises.isEmpty) return false;
    final exerciseIds = exercises.map((e) => e.id).toSet();
    return _inProgressExerciseIds.containsAll(exerciseIds);
  }
  
  // ... All other methods are unchanged and correct ...
  void updateUserName(String newName) { _userName = newName; notifyListeners(); }
  WorkoutStatus getWorkoutStatusForDate(DateTime date) { final today = DateUtils.dateOnly(DateTime.now()); final dateOnly = DateUtils.dateOnly(date); if (dateOnly.isAfter(today)) return WorkoutStatus.Future; if (_workoutLog.containsKey(dateOnly)) return WorkoutStatus.Completed; final dayName = DateFormat('EEEE').format(dateOnly); final plan = _weeklyPlan[dayName]; if (plan == null || plan.contains('Rest')) return WorkoutStatus.Rest; return WorkoutStatus.Skipped; }
  void logWorkout(DateTime date, Workout workout) { final loggedWorkout = Workout( id: workout.id, name: workout.name, exercises: workout.exercises.map((ex) { return Exercise( id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps, description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl, isCompleted: _inProgressExerciseIds.contains(ex.id) ); }).toList(), ); _workoutLog[DateUtils.dateOnly(date)] = loggedWorkout; notifyListeners(); }
  void deleteLoggedWorkout(DateTime date) { _workoutLog.remove(DateUtils.dateOnly(date)); notifyListeners(); }
  void markAllExercisesAsComplete(List<Exercise> exercises) { for (var ex in exercises) { _inProgressExerciseIds.add(ex.id); } notifyListeners(); }
  void deleteExercise(String exerciseId) { _customExercises.removeWhere((ex) => ex.id == exerciseId); for (var workout in _workouts) { workout.exercises.removeWhere((ex) => ex.id == exerciseId); } notifyListeners(); }
  void updateExercise(Exercise updatedExercise) { int index = _customExercises.indexWhere((ex) => ex.id == updatedExercise.id); if (index != -1) { _customExercises[index] = updatedExercise; notifyListeners(); return; } for (var workout in _workouts) { index = workout.exercises.indexWhere((ex) => ex.id == updatedExercise.id); if (index != -1) { workout.exercises[index] = updatedExercise; notifyListeners(); return; } } }
  void addCustomExercise({ required String name, required String targetMuscle, String? description, required int sets, required int reps, String? imageUrl, String? videoUrl }) { final newExercise = Exercise(id: 'custom_${DateTime.now().toIso8601String()}', name: name, targetMuscle: targetMuscle, description: description, sets: sets, reps: reps, imageUrl: imageUrl, videoUrl: videoUrl); _customExercises.add(newExercise); notifyListeners(); }
  void logUserWeight(double weight) { _weightHistory.removeWhere((key, value) => DateUtils.isSameDay(key, _selectedDate)); _weightHistory[_selectedDate] = weight; notifyListeners(); }
  void changeSelectedDate(DateTime newDate) { _selectedDate = newDate; notifyListeners(); }
  void updateWeeklyPlan(String day, List<String> muscleGroups) { _weeklyPlan[day] = muscleGroups; notifyListeners(); }
  void updateProfilePicture(String imagePath) { _profileImagePath = imagePath; notifyListeners(); }
}
