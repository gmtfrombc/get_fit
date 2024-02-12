import 'package:flutter/material.dart';
import 'package:get_fit/models/user_workout_model.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:get_fit/models/workout_model.dart';
import 'package:get_fit/services/firebase_services.dart';

class UserWorkoutProvider with ChangeNotifier {
  String _selectedGroup = '';
  final List<ExerciseDetails> _userWorkoutGroups = [];

  String get selectedGroup => _selectedGroup;
  List<ExerciseDetails> get userWorkoutGroups => _userWorkoutGroups;

  List<ExerciseSummary> get exercisesForSelectedGroup {
    final groupDetail =
        _userWorkoutGroups.firstWhereOrNull((g) => g.group == _selectedGroup);

    return groupDetail?.exercises ?? [];
  }

  void setSelectedGroup(String group) {
    _selectedGroup = group;
    notifyListeners();
  }

  Future<void> saveCurrentWorkoutGroups(String userId) async {
    // Assuming you want to update IDs and save only for the selected group
    var selectedGroupDetails = _userWorkoutGroups
        .firstWhereOrNull((group) => group.group == _selectedGroup);
    if (selectedGroupDetails != null) {
      updateExerciseIds(
          [selectedGroupDetails]); // Update IDs only for the selected group
      await FirebaseServices().saveUserGroupWorkouts(
          userId,
          [selectedGroupDetails],
          _selectedGroup); // Save only the selected group
    }
    notifyListeners();
  }

  void updateExerciseIds(List<ExerciseDetails> workoutGroups) {
    for (var group in workoutGroups) {
      for (var i = 0; i < group.exercises.length; i++) {
        group.exercises[i].exerciseId =
            i + 1; // Correctly updates exerciseId based on order
      }
    }
  }

  void reorderExercises(int oldIndex, int newIndex) {
    var exercise = exercisesForSelectedGroup.removeAt(oldIndex);
    exercisesForSelectedGroup.insert(newIndex, exercise);
    notifyListeners();
  }

  void deleteExerciseFromSelectedGroup(int exerciseId) {
    final groupDetail =
        _userWorkoutGroups.firstWhereOrNull((g) => g.group == _selectedGroup);
    if (groupDetail != null) {
      int indexToRemove = groupDetail.exercises
          .indexWhere((exercise) => exercise.exerciseId == exerciseId);
      if (indexToRemove != -1) {
        groupDetail.exercises.removeAt(indexToRemove);
        notifyListeners();
      }
    }
  }

  Future<void> fetchUserWorkoutGroups(String userId) async {
    FirebaseServices services = FirebaseServices();
    List<UserWorkoutModel> userWorkoutGroups =
        await services.fetchUserWorkoutGroups(userId);

    _userWorkoutGroups.clear();
    for (var workoutGroupModel in userWorkoutGroups) {
      for (var groupDetail in workoutGroupModel.workoutGroups) {
        if (groupDetail.group == _selectedGroup) {
          _userWorkoutGroups.add(groupDetail);
        }
      }
    }
    notifyListeners();
  }

  bool addExerciseToSelectedGroup(ExerciseSummary exercise) {
    // Attempt to find the group detail for the currently selected group.
    var groupDetail = _userWorkoutGroups
        .firstWhereOrNull((detail) => detail.group == _selectedGroup);

    // If no detail exists for the selected group, create a new one.
    if (groupDetail == null) {
      groupDetail = ExerciseDetails(group: _selectedGroup, exercises: []);
      _userWorkoutGroups.add(groupDetail);
      debugPrint('Created new group detail for $_selectedGroup');
    }

    // Check if the exercise already exists in the group by name.
    bool exerciseExists =
        groupDetail.exercises.any((ex) => ex.name == exercise.name);

    if (!exerciseExists) {
      // If the exercise doesn't exist, add it and notify listeners.
      groupDetail.exercises.add(exercise);
      notifyListeners();
      return true; // Exercise added successfully.
    } else {
      return false; // Exercise already exists in the group.
    }
  }
}
