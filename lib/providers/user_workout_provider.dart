import 'package:flutter/material.dart';
import 'package:get_fit/models/user_exercises.dart';
import 'package:get_fit/models/all_exercises.dart';
import 'package:get_fit/models/user_workout_model.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:get_fit/models/user_workouts.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/services/firebase_services.dart';
import 'package:provider/provider.dart';

class UserWorkoutProvider with ChangeNotifier {
  WorkoutSession? currentWorkoutSession;
  int _currentExerciseIndex = 0;

  int get currentExerciseIndex => _currentExerciseIndex;

  String _selectedWorkoutGroup = '';

  int _currentGroupIndex = 0; // Default to the first group

  int get currentGroupIndex => _currentGroupIndex;

  bool get isLastExercise =>
      currentExerciseIndex == exercisesForSelectedWorkoutGroup.length - 1;

  final List<UserExercises> _userExerciseList = [];

  String get selectedWorkoutGroup => _selectedWorkoutGroup;
  List<UserExercises> get userExerciseList => _userExerciseList;

  List<AllExercises> get exercisesForSelectedWorkoutGroup {
    final exerciseDetails = _userExerciseList
        .firstWhereOrNull((g) => g.group == _selectedWorkoutGroup);
    return exerciseDetails?.exercises ?? [];
  }

  void setSelectedGroup(String workoutGroup) {
    _selectedWorkoutGroup = workoutGroup;
    _currentGroupIndex = findWorkoutGroupIndex(workoutGroup)!;
    notifyListeners();
  }

  void nextExercise() {
    if (!isLastExercise) {
      _currentExerciseIndex++;
      notifyListeners();
    }
  }

  void initializeWorkoutSession() {
    currentWorkoutSession = WorkoutSession(
      date: DateTime.now(),
      workoutGroup: _selectedWorkoutGroup,
      userId: "", // This will need to be set when saving the session
      dailyWorkout: [],
    );
  }

  Future<void> saveWorkoutSession(BuildContext context) async {
    final userWorkoutProvider =
        Provider.of<UserWorkoutProvider>(context, listen: false);
    final userId =
        Provider.of<AuthProviderClass>(context, listen: false).currentUser!.uid;
    debugPrint(
        'Saving workout session: ${userWorkoutProvider.currentWorkoutSession!.toMap()}');
    try {
      userWorkoutProvider.currentWorkoutSession?.userId = userId;
      debugPrint('User ID: $userId');
      await FirebaseServices().saveWorkoutSession(
          userWorkoutProvider.currentWorkoutSession!.toMap(), userId);
      userWorkoutProvider.clearWorkoutSession();
    } catch (e) {
      debugPrint('Error saving workout session: $e');
      throw Exception('Failed to save workout session');
    }
  }

  void addToWorkoutSession(
      String exerciseName, List<Map<String, dynamic>> sets) {
    if (currentWorkoutSession == null) {
      initializeWorkoutSession();
    }

    List<Sets> transformedSets = sets
        .map((set) => Sets(
              reps: int.parse(set['reps']),
              weight: int.parse(set['weight']),
              setNumber: set['set'].toString(),
            ))
        .toList();

    UserWorkouts currentExercise = UserWorkouts(
      exerciseName: exerciseName,
      sets: transformedSets,
    );

    currentWorkoutSession!.dailyWorkout.add(currentExercise);
    notifyListeners();
  }

  void clearWorkoutSession() {
    currentWorkoutSession = null;
  }

  Future<void> saveCurrentWorkoutGroups(String userId) async {
    var selectedExerciseDetails = _userExerciseList.firstWhereOrNull(
        (exercise) => exercise.group == _selectedWorkoutGroup);
    if (selectedExerciseDetails != null) {
      updateExerciseIds(
          [selectedExerciseDetails]); // Update IDs only for the selected group
      await FirebaseServices().saveUserGroupWorkouts(
          userId,
          [selectedExerciseDetails],
          _selectedWorkoutGroup); // Save only the selected group
    }
    notifyListeners();
  }

  void updateExerciseIds(List<UserExercises> userExerciseList) {
    for (var exercise in userExerciseList) {
      for (var i = 0; i < exercise.exercises.length; i++) {
        exercise.exercises[i].exerciseId =
            i + 1; // Correctly updates exerciseId based on order
      }
    }
  }

  void reorderExercises(int oldIndex, int newIndex) {
    var exercise = exercisesForSelectedWorkoutGroup.removeAt(oldIndex);
    exercisesForSelectedWorkoutGroup.insert(newIndex, exercise);
    notifyListeners();
  }

  void deleteExerciseFromSelectedGroup(int exerciseId) {
    final selectedExerciseDetails = _userExerciseList
        .firstWhereOrNull((g) => g.group == _selectedWorkoutGroup);
    if (selectedExerciseDetails != null) {
      int indexToRemove = selectedExerciseDetails.exercises
          .indexWhere((exercise) => exercise.exerciseId == exerciseId);
      if (indexToRemove != -1) {
        selectedExerciseDetails.exercises.removeAt(indexToRemove);
        notifyListeners();
      }
    }
  }

  int? findWorkoutGroupIndex(String groupName) {
    debugPrint('Finding index for $groupName');
    for (var i = 0; i < _userExerciseList.length; i++) {
      for (var j = 0; j < _userExerciseList[i].exercises.length; j++) {
        debugPrint('Group: ${_userExerciseList[i].group}');
        debugPrint('Exercise: ${_userExerciseList[i].exercises[j].name}');
      }
    }

    return _userExerciseList.indexWhere((workout) {
      debugPrint(' index is ${_userExerciseList.indexOf(workout)}');
      debugPrint(' index was found? ${workout.group == groupName}');
      return workout.group == groupName;
    });
  }

  Future<void> fetchUserWorkoutGroups(String userId) async {
    FirebaseServices services = FirebaseServices();
    List<UserWorkoutModel> userWorkoutGroups =
        await services.fetchUserWorkoutGroups(userId);

    _userExerciseList.clear();
    for (var workoutGroupModel in userWorkoutGroups) {
      for (var groupDetail in workoutGroupModel.exerciseList) {
        if (groupDetail.group == _selectedWorkoutGroup) {
          _userExerciseList.add(groupDetail);
        }
      }
    }
    notifyListeners();
  }

  bool addExerciseToSelectedGroup(AllExercises exercise) {
    // Attempt to find the group detail for the currently selected group.
    var selectedExerciseDetails = _userExerciseList.firstWhereOrNull(
        (exercise) => exercise.group == _selectedWorkoutGroup);

    // If no detail exists for the selected group, create a new one.
    if (selectedExerciseDetails == null) {
      selectedExerciseDetails =
          UserExercises(group: _selectedWorkoutGroup, exercises: []);
      _userExerciseList.add(selectedExerciseDetails);
      debugPrint('Created new group detail for $_selectedWorkoutGroup');
    }

    // Check if the exercise already exists in the group by name.
    bool exerciseExists =
        selectedExerciseDetails.exercises.any((ex) => ex.name == exercise.name);

    if (!exerciseExists) {
      // If the exercise doesn't exist, add it and notify listeners.
      selectedExerciseDetails.exercises.add(exercise);
      notifyListeners();
      return true; // Exercise added successfully.
    } else {
      return false; // Exercise already exists in the group.
    }
  }
}
