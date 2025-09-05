import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitlyf/providers/workout_provider.dart';
import 'package:fitlyf/models/workout_model.dart'; // We need this
import 'package:fitlyf/screens/workout_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workout = workoutProvider.selectedWorkout; // This is a Workout?

    return Scaffold(
      appBar: AppBar(
        title: Text('FitLfy'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s Workout',
                  style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 16),
              // THE FIX: Check if workout is null before building the card
              if (workout != null)
                 _buildWorkoutCard(context, workout) // Pass the Workout object
              else
                Center(
                  child: Text("No workout selected for today."),
                ),

              SizedBox(height: 24),
              _buildWeightTracker(context),
              SizedBox(height: 24),
              _buildCalendar(context),
            ],
          ),
        ),
      ),
    );
  }

  // THE FIX: Change the parameter type from WorkoutSession to Workout
  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    return Card(
      child: ListTile(
        title: Text(workout.name),
        subtitle: Text('${workout.exercises.length} exercises'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => WorkoutDetailScreen(workout: workout),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeightTracker(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Weight Tracker',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Text(
              "${provider.latestWeight} kg",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Theme.of(context).primaryColor),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              child: Text('Log New Weight'),
              onPressed: () => _showLogWeightDialog(context),
            )
          ],
        ),
      ),
    );
  }

  void _showLogWeightDialog(BuildContext context) {
    final weightController = TextEditingController();
    final provider = Provider.of<WorkoutProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log Your Weight'),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Weight (kg)'),
        ),
        actions: [
          TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            child: Text('Save'),
            onPressed: () {
              final newWeight = double.tryParse(weightController.text);
              if (newWeight != null) {
                provider.logUserWeight(newWeight);
              }
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final today = DateTime.now();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This Week', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 8),
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (ctx, index) {
              final date = today.add(Duration(days: index - today.weekday + 1));
              final bool isActive = DateUtils.isSameDay(date, provider.selectedDate);
              
              return GestureDetector(
                onTap: () {
                  provider.changeSelectedDate(date);
                },
                child: Card(
                  color: isActive ? Theme.of(context).primaryColor : null,
                  child: Container(
                    width: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
                          style: TextStyle(color: isActive ? Colors.white : null),
                        ),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
