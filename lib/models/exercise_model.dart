class Exercise {
  final String id;
  final String name;
  final String targetMuscle;
  final String? description; // <-- ADD THIS LINE
  final int sets;
  final int reps;
  bool isCompleted;
  final String? imageUrl;
  final String? videoUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    this.description, // <-- ADD THIS LINE
    required this.sets,
    required this.reps,
    this.isCompleted = false,
    this.imageUrl,
    this.videoUrl,
  });
}
