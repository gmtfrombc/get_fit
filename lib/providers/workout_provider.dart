import 'package:flutter/material.dart';
import 'package:get_fit/models/workout_model.dart';
import 'package:get_fit/services/firebase_services.dart';

class WorkoutProvider with ChangeNotifier {
  final FirebaseServices _firebaseServices = FirebaseServices();

  List<WorkoutModel> _workouts = [];

  List<WorkoutModel> get workouts => _workouts;

//This function is used to fetch the workouts from the FirebaseServices class. It sets the list _workouts to the fetched workouts. Workouts is a list of workoutModels that includes the group, image, color, and list of AllExercises. The function is used in WorkoutScreen and presenets the results in the GridView.
  Future<void> fetchWorkouts() async {
    try {
      _workouts = await _firebaseServices.fetchWorkouts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching workouts: $e');
      throw Exception('Error fetching workouts: $e');
    }
  }

//This function is used to fetch the workouts by group from the FirebaseServices class. It takes in the group and sets the list _workouts to the fetched workouts. Workouts is a list of workoutModels that includes the group, image, color, and list of AllExercises. It is used in AddWorkoutScreen to fetch the workouts by group and present them to the user in order to add to the existing daily workout.
  Future<void> fetchWorkoutsByGroup(String group) async {
    try {
      _workouts = await _firebaseServices.fetchWorkoutsByGroup(group);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching workouts by group: $e');
      throw Exception('Error fetching workouts by group: $e');
    }
  }

  // int? findWorkoutIndex(String groupName) {
  //   return _workouts.indexWhere((workout) => workout.group == groupName);
  // }
}
