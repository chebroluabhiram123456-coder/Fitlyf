import 'package:flutter/material.dart';

class WorkoutProvider with ChangeNotifier {

  // This is the sample weight history data that was missing.
  final Map<DateTime, double> _weightHistory = {
    DateTime.now().subtract(const Duration(days: 10)): 78.5,
    DateTime.now().subtract(const Duration(days: 7)): 78.0,
    DateTime.now().subtract(const Duration(days: 4)): 77.8,
    DateTime.now().subtract(const Duration(days: 1)): 77.2,
  };

  // This "getter" allows other parts of your app to safely access the weight history.
  Map<DateTime, double> get weightHistory => _weightHistory;

  // You can add other data and functions for your provider below.
  // For example, a function to add a new weight entry:
  void addWeightEntry(DateTime date, double weight) {
    _weightHistory[date] = weight;
    // notifyListeners() tells any widget listening to this provider to rebuild.
    notifyListeners();
  }

}
