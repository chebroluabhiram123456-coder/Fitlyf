class Exercise {
  final String id;
  final String name;
  final String targetMuscle;
  final int sets; // Added this
  final int reps; // Added this
  bool isCompleted;

  Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.sets, // Added this
    required this.reps, // Added this
    this.isCompleted = false,
  });
}
