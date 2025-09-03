import 'package.flutter/material.dart';
import 'package.fitlyf/models/exercise_model.dart';
import 'package.fitlyf/models/workout_session.dart';

class WorkoutProvider with ChangeNotifier {
  // This is your library of all created exercises. Starts empty.
  final List<Exercise> _masterExerciseList = [];

  // This will hold the workouts for different dates as you create them.
  final Map<DateTime, WorkoutSession> _dailyWorkouts = {};

  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());
  late WorkoutSession _selectedWorkout;

  WorkoutProvider() {
    // Initialize with an empty workout for today
    _loadWorkoutForDate(_selectedDate);
  }

  // --- GETTERS ---
  DateTime get selectedDate => _selectedDate;
  WorkoutSession get selectedWorkout => _selectedWorkout;
  List<Exercise> get masterExerciseList => _masterExerciseList;

  // --- METHODS ---
  void _loadWorkoutForDate(DateTime date) {
    // If a workout for the date exists, load it. Otherwise, create an empty one.
    _selectedWorkout = _dailyWorkouts[date] ?? WorkoutSession(
      date: date,
      name: 'Plan a workout!',
      exercises: [],
    );
  }

  void changeSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    _loadWorkoutForDate(newDate);
    notifyListeners();
  }

  // Adds a new exercise to your main library
  void addExerciseToMasterList(Exercise exercise) {
    _masterExerciseList.add(exercise);
    notifyListeners();
  }

  // Creates a workout for the selected day based on a muscle group
  void createWorkoutForDay(DateTime date, String muscleGroup) {
    // Find all exercises in your library that match the muscle group
    final exercisesForMuscle = _masterExerciseList
        .where((ex) => ex.muscleGroup.toLowerCase() == muscleGroup.toLowerCase())
        .toList();

    // Create a new workout session with those exercises
    final newWorkout = WorkoutSession(
      date: date,
      name: muscleGroup,
      exercises: exercisesForMuscle,
    );

    // Save this workout for the specific date
    _dailyWorkouts[date] = newWorkout;
    
    // Update the currently selected workout if it's for the same day
    if (DateUtils.isSameDay(_selectedDate, date)) {
      _selectedWorkout = newWorkout;
    }

    notifyListeners();
  }

  void toggleExerciseCompletion(String exerciseId) {
    final exercise = _selectedWorkout.exercises.firstWhere((ex) => ex.id == exerciseId);
    exercise.isCompleted = !exercise.isCompleted;
    notifyListeners();
  }
}
