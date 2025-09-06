import 'package:flutter/material.dart';
import 'package:fitlyf/widgets/frosted_glass_card.dart';

class WorkoutLogScreen extends StatelessWidget {
  const WorkoutLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Workout Log'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: FrostedGlassCard(
          child: Center(
            child: Text(
              'Your workout history will appear here.\nFeature coming soon!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
