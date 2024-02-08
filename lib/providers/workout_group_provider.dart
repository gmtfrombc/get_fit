import 'package:flutter/material.dart';
import 'package:get_fit/models/user_workouts_model.dart';
import 'package:get_fit/services/firebase_services.dart';

class WorkoutGroupProvider with ChangeNotifier {
  String _selectedGroup = '';
  List<WorkoutDetail> _userWorkoutDetails = [];

  String get selectedGroup => _selectedGroup;
  List<WorkoutDetail> get userWorkoutDetails => _userWorkoutDetails;

  void deleteWorkout(String workoutName) {
    _userWorkoutDetails.removeWhere((element) => element.name == workoutName);
    notifyListeners();
  }

  Future<void> setSelectedGroupAndFetchWorkouts(String group, String userId) async {
    _selectedGroup = group;
    await fetchUserWorkouts(userId);
    notifyListeners();
  }

  Future<void> fetchUserWorkouts(String userId) async {
    FirebaseServices services = FirebaseServices();
    List<UserWorkoutModel> userWorkouts = await services.fetchUserWorkouts(userId, _selectedGroup);

    _userWorkoutDetails = [];
    for (var workout in userWorkouts) {
      _userWorkoutDetails.addAll(workout.workouts.where((detail) => detail.group == _selectedGroup));
    }

    notifyListeners();
  }
}


