import 'package:flutter/material.dart';
// ... (other imports)

class _HomeScreenState extends State<HomeScreen> {
  // ... (existing code)

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        final workout = provider.selectedWorkout;

        return Container(
          // ... (existing decoration)
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView( // <-- Wrap with SingleChildScrollView
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCalendarHeader(provider),
                      const SizedBox(height: 30),
                      const Text(
                        "Get ready, AB",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Here's your plan for ${DateFormat('EEEE').format(provider.selectedDate)}",
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      _buildWeightLogger(context, provider), // <-- ADD THIS NEW WIDGET
                      const SizedBox(height: 20),
                      _buildWorkoutCard(context, workout, provider),
                      const SizedBox(height: 20),
                      _buildAddExerciseButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ... (other _build methods)

  // --- NEW: Widget for Logging Weight ---
  Widget _buildWeightLogger(BuildContext context, WorkoutProvider provider) {
    final todaysWeight = provider.todaysWeight;
    final TextEditingController weightController = TextEditingController();

    void _showEditDialog() {
      weightController.text = todaysWeight?.toString() ?? "";
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2D1458),
            title: const Text('Log Your Weight', style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: weightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Enter weight in kg",
                hintStyle: TextStyle(color: Colors.white54),
                suffixText: 'kg',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () {
                  final weight = double.tryParse(weightController.text);
                  if (weight != null) {
                    provider.logWeight(weight);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save', style: TextStyle(color: Colors.purple.shade200)),
              ),
            ],
          );
        },
      );
    }

    if (todaysWeight == null) {
      // View when no weight is logged for today
      return GestureDetector(
        onTap: _showEditDialog,
        child: FrostedGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: const Row(
            children: [
              Icon(Icons.scale, color: Colors.white, size: 28),
              SizedBox(width: 15),
              Text(
                "Log Your Today's Weight",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    } else {
      // View when weight has been logged
      return FrostedGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 28),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Weight",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                Text(
                  "$todaysWeight kg",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white70),
              onPressed: _showEditDialog,
            ),
          ],
        ),
      );
    }
  }
}
