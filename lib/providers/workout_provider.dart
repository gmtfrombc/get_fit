import 'package:flutter/material.dart';
import 'package:get_fit/models/workout_model.dart';
import 'package:get_fit/services/firebase_services.dart';

class WorkoutProvider with ChangeNotifier {
  final FirebaseServices _firebaseServices = FirebaseServices();

  List<WorkoutModel> _workouts = [];

  List<WorkoutModel> get workouts => _workouts;

  Future<void> fetchWorkouts() async {
    try {
      _workouts = await _firebaseServices.fetchWorkouts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching workouts: $e');
      throw Exception('Error fetching workouts: $e');
    }
  }

  Future<void> fetchWorkoutsByGroup(String group) async {
    try {
      _workouts = await _firebaseServices.fetchWorkoutsByGroup(group);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching workouts by group: $e');
      throw Exception('Error fetching workouts by group: $e');
    }
  }
}
