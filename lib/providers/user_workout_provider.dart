import 'package:flutter/material.dart';
import 'package:get_fit/models/user_workouts_model.dart';
import 'package:get_fit/models/workout_model.dart';
import 'package:get_fit/services/firebase_services.dart';

class UserWorkoutProvider with ChangeNotifier {
  String _selectedGroup = '';
  List<WorkoutDetail> _userWorkoutDetails = [];

  String get selectedGroup => _selectedGroup;
  List<WorkoutDetail> get userWorkoutDetails => _userWorkoutDetails;

  void deleteWorkout(String workoutName) {
    _userWorkoutDetails.removeWhere((element) => element.name == workoutName);
    notifyListeners();
  }

  void addWorkout(WorkoutDetail workout) {
    _userWorkoutDetails.add(workout);
    notifyListeners();
  }

  Future<void> setSelectedGroupAndFetchWorkouts(
      String group, String userId) async {
    _selectedGroup = group;
    await fetchUserWorkouts(userId);
    notifyListeners();
  }

  Future<void> fetchUserWorkouts(String userId) async {
    FirebaseServices services = FirebaseServices();
    List<UserWorkoutModel> userWorkouts =
        await services.fetchUserWorkouts(userId, _selectedGroup);
    _userWorkoutDetails.clear();
    _userWorkoutDetails = [];
    for (var workout in userWorkouts) {
      _userWorkoutDetails.addAll(
          workout.workouts.where((detail) => detail.group == _selectedGroup));
    }
    notifyListeners();
  }

  bool addExerciseToWorkout(ExerciseSummary exercise, Workout userWorkout) {
    bool workoutExists = _userWorkoutDetails.any((detail) =>
        detail.group == userWorkout.group && detail.name == exercise.name);
    if (!workoutExists) {
      var newWorkout = WorkoutDetail(
          group: userWorkout.group, name: exercise.name, exercises: [exercise]);
      _userWorkoutDetails.add(newWorkout);
      notifyListeners();
      return true; // Added successfully
    } else {
      return false; // Workout already exists
    }
  }
}
