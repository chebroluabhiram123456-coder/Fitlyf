import 'package:flutter/material.dart';

class AddExerciseScreen extends StatelessWidget {
  const AddExerciseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Exercise'),
      ),
      body: const Center(
        child: Text(
          'Exercise creation feature coming soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
