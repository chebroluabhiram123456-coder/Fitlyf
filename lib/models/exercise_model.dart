import 'package:fitlyf/models/set_log_model.dart';

class Exercise {
  final String id;
  final String name;
  final String targetMuscle;
  final String? description;
  final int sets;
  final int reps;
  bool isCompleted;
  final String? imageUrl;
  final String? videoUrl;
  
  List<SetLog> setsLogged;

  Exercise({
    required this.id,
    required this.name,
    required this.targetMuscle,
    this.description,
    required this.sets,
    required this.reps,
    this.isCompleted = false,
    this.imageUrl,
    this.videoUrl,
    this.setsLogged = const [],
  });
}
