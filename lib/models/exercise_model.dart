class Exercise {
  final String id;
  final String name;
  final String targetMuscle;
  final int sets;
  final int reps;
  bool isCompleted;
  final String? imageUrl; // <-- ADD THIS
  final String? videoUrl; // <-- ADD THIS

  Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.sets,
    required this.reps,
    this.isCompleted = false,
    this.imageUrl, // <-- ADD THIS
    this.videoUrl, // <-- ADD THIS
  });
}
