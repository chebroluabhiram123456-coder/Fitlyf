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
  final Map<DateTime, double> _weightHistory = {};
  final Map<DateTime, Workout> _workoutLog = {};
  final List<Exercise> _customExercises = [];
  Set<String> _inProgressExerciseIds = {};
  final Map<String, double> _personalBests = {};
  final Map<String, bool> _achievements = {'first_workout': false};

  final List<Workout> _workouts = [
    Workout( id: 'w1', name: 'Full Body A', exercises: [
        Exercise(id: 'ex1', name: 'Barbell Incline Bench Press', targetMuscle: 'Chest', sets: 4, reps: 8),
        Exercise(id: 'ex2', name: 'Barbell Push Press', targetMuscle: 'Shoulders', sets: 3, reps: 10),
    ]),
    Workout( id: 'w2', name: 'Full Body B', exercises: [
        Exercise(id: 'ex3', name: 'Squats', targetMuscle: 'Legs', sets: 5, reps: 5),
        Exercise(id: 'ex4', name: 'Deadlifts', targetMuscle: 'Back', sets: 1, reps: 5),
    ]),
  ];
  
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

  bool isExerciseInProgressCompleted(String exerciseId) => _inProgressExerciseIds.contains(exerciseId);
  
  // THE FIX 1: This getter is now "session-aware" and "log-aware".
  Workout? get selectedWorkout {
    final dateOnly = DateUtils.dateOnly(_selectedDate);
    // Priority 1: Check if there's a permanent log for this day.
    if (_workoutLog.containsKey(dateOnly)) {
      return _workoutLog[dateOnly];
    }

    final dayName = DateFormat('EEEE').format(_selectedDate);
    final targetMuscles = _weeklyPlan[dayName];
    if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) return null;
    
    final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList();
    
    // Priority 2: Return a temporary workout with the live session's completion data.
    return Workout(
      id: 'day_${dayName.toLowerCase()}',
      name: targetMuscles.join(' & '),
      exercises: exercisesForDay.map((ex) => Exercise(
        id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps,
        description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl,
        isCompleted: _inProgressExerciseIds.contains(ex.id)
      )).toList(),
    );
  }
  
  // THE FIX 2: This getter is also now fully synced for the Progress screen.
  Workout? get getTodaysWorkout {
    final today = DateUtils.dateOnly(DateTime.now());
    if (_workoutLog.containsKey(today)) {
      return _workoutLog[today];
    }
    
    final dayName = DateFormat('EEEE').format(today);
    final targetMuscles = _weeklyPlan[dayName];
    if (targetMuscles == null || targetMuscles.isEmpty || targetMuscles.contains('Rest')) return null;
    
    final exercisesForDay = allExercises.where((ex) => targetMuscles.contains(ex.targetMuscle)).toList();

    return Workout(
      id: 'today_workout',
      name: targetMuscles.join(' & '),
      exercises: exercisesForDay.map((ex) => Exercise(
        id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps,
        description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl,
        isCompleted: _inProgressExerciseIds.contains(ex.id)
      )).toList(),
    );
  }

  List<Exercise> get allExercises { return [..._workouts.expand((workout) => workout.exercises), ..._customExercises]; }
  
  // --- Methods ---
  
  void startWorkoutSession() {
    final dateOnly = DateUtils.dateOnly(_selectedDate);
    if (_workoutLog.containsKey(dateOnly)) {
      final loggedWorkout = _workoutLog[dateOnly]!;
      _inProgressExerciseIds = loggedWorkout.exercises.where((ex) => ex.isCompleted).map((ex) => ex.id).toSet();
    } else {
      _inProgressExerciseIds.clear();
    }
    notifyListeners();
  }

  void toggleInProgressExerciseCompletion(String exerciseId, bool isCompleted) {
    if (isCompleted) { _inProgressExerciseIds.add(exerciseId); }
    else { _inProgressExerciseIds.remove(exerciseId); }
    notifyListeners();
  }

  bool areAllExercisesComplete(List<Exercise> exercises) {
    if (exercises.isEmpty) return false;
    final exerciseIds = exercises.map((e) => e.id).toSet();
    return _inProgressExerciseIds.containsAll(exerciseIds);
  }
  
  void logWorkout(DateTime date, Workout workout) {
    final dateOnly = DateUtils.dateOnly(date);
    final loggedWorkout = Workout(
      id: workout.id, name: workout.name,
      exercises: workout.exercises.map((ex) {
        return Exercise(
          id: ex.id, name: ex.name, targetMuscle: ex.targetMuscle, sets: ex.sets, reps: ex.reps,
          description: ex.description, imageUrl: ex.imageUrl, videoUrl: ex.videoUrl,
          isCompleted: _inProgressExerciseIds.contains(ex.id)
        );
      }).toList(),
    );
    _workoutLog[dateOnly] = loggedWorkout;
    if (_achievements['first_workout'] == false) { _achievements['first_workout'] = true; }
    notifyListeners();
  }
  
  // ... All other methods are unchanged and correct ...
  void updateUserName(String newName) { _userName = newName; notifyListeners(); }
  WorkoutStatus getWorkoutStatusForDate(DateTime date) { final today = DateUtils.dateOnly(DateTime.now()); final dateOnly = DateUtils.dateOnly(date); if (dateOnly.isAfter(today)) return WorkoutStatus.Future; if (_workoutLog.containsKey(dateOnly)) return WorkoutStatus.Completed; final dayName = DateFormat('EEEE').format(dateOnly); final plan = _weeklyPlan[dayName]; if (plan == null || plan.contains('Rest')) return WorkoutStatus.Rest; return WorkoutStatus.Skipped; }
  void deleteLoggedWorkout(DateTime date) { _workoutLog.remove(DateUtils.dateOnly(date)); notifyListeners(); }
  void markAllExercisesAsComplete(List<Exercise> exercises) { for (var ex in exercises) _inProgressExerciseIds.add(ex.id); notifyListeners(); }
  void logSet(String exerciseId, int reps, double weight) { if (weight > (_personalBests[exerciseId] ?? 0)) _personalBests[exerciseId] = weight; notifyListeners(); }
  void deleteExercise(String exerciseId) { _customExercises.removeWhere((ex) => ex.id == exerciseId); for (var workout in _workouts) workout.exercises.removeWhere((ex) => ex.id == exerciseId); notifyListeners(); }
  void updateExercise(Exercise updatedExercise) { int index = _customExercises.indexWhere((ex) => ex.id == updatedExercise.id); if (index != -1) { _customExercises[index] = updatedExercise; notifyListeners(); return; } for (var workout in _workouts) { index = workout.exercises.indexWhere((ex) => ex.id == updatedExercise.id); if (index != -1) workout.exercises[index] = updatedExercise; notifyListeners(); return; } }
  void addCustomExercise({ required String name, required String targetMuscle, String? description, required int sets, required int reps, String? imageUrl, String? videoUrl }) { final newExercise = Exercise(id: 'custom_${DateTime.now().toIso8601String()}', name: name, targetMuscle: targetMuscle, description: description, sets: sets, reps: reps, imageUrl: imageUrl, videoUrl: videoUrl); _customExercises.add(newExercise); notifyListeners(); }
  void logUserWeight(double weight) { _weightHistory.removeWhere((key, value) => DateUtils.isSameDay(key, _selectedDate)); _weightHistory[_selectedDate] = weight; notifyListeners(); }
  void changeSelectedDate(DateTime newDate) { _selectedDate = newDate; notifyListeners(); }
  void updateWeeklyPlan(String day, List<String> muscleGroups) { _weeklyPlan[day] = muscleGroups; notifyListeners(); }
  void updateProfilePicture(String imagePath) { _profileImagePath = imagePath; notifyListeners(); }
}
