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
  List<WorkoutSession> _dailyWorkoutsByDate = [];

  List<WorkoutSession> get dailyWorkoutsByDate => _dailyWorkoutsByDate;

  int _currentExerciseIndex = 0;

  int get currentExerciseIndex => _currentExerciseIndex;

  String _selectedWorkoutGroup = '';

  final int _currentGroupIndex = 0; // Default to the first group

  int get currentGroupIndex => _currentGroupIndex;

  bool get isLastExercise =>
      currentExerciseIndex == exercisesForSelectedWorkoutGroup.length - 1;

  final List<WorkoutGroups> _userExerciseList = [];

  String get selectedWorkoutGroup => _selectedWorkoutGroup;
  List<WorkoutGroups> get userExerciseList => _userExerciseList;

//This function is used to set the selected group. It takes in the workoutGroup, for example 'Strength' and sets the selectedWorkoutGroup to that workoutGroup. It is used in the WorkoutScreen to set the selected group and present the exercises for that group in the initState and the WidgetsBinding.intance
  void setSelectedGroup(String workoutGroup) {
    _selectedWorkoutGroup = workoutGroup;

    notifyListeners();
  }

//This is the list of exercises for the selected workout group that is based on the group name. So, it should return a list of exercises for the selected group, for example 'Strength' or 'Endurance', It is used in SetScreen to present the exercises for the selected group in the ListView. The _userExerciseList is first created in the fetchUserWorkoutGroups function and then the exercisesForSelectedWorkoutGroup is used to present the exercises for the selected group in the ListView.
  List<AllExercises> get exercisesForSelectedWorkoutGroup {
    final exerciseDetails = _userExerciseList
        .firstWhereOrNull((g) => g.group == _selectedWorkoutGroup);
    return exerciseDetails?.exercises ?? [];
  }

  void nextExercise(String? userId) {

    if (!isLastExercise) {
      _currentExerciseIndex++;

      notifyListeners();
    }
    String selectedExercise =
        exercisesForSelectedWorkoutGroup[_currentExerciseIndex].name;
    debugPrint('Selected exercise for NEXT exercise is: $selectedExercise');
    fetchUserWorkoutsForAllDates(
        userId!, selectedWorkoutGroup, selectedExercise);
    notifyListeners();
  }

  void initializeWorkoutSession() {
    currentWorkoutSession = WorkoutSession(
      date: DateTime.now(),
      workoutGroup: _selectedWorkoutGroup,
      userId: "", // This will need to be set when saving the session
      dailyWorkout: [],
    );
    _currentExerciseIndex = 0;
  }

//This method is used in SetScreen to save the workout session to Firebase and clear the workout session once the user has completed their daily workout.
  Future<void> saveWorkoutSession(BuildContext context) async {
    final userWorkoutProvider =
        Provider.of<UserWorkoutProvider>(context, listen: false);
    final userId =
        Provider.of<AuthProviderClass>(context, listen: false).currentUser!.uid;
    try {
      userWorkoutProvider.currentWorkoutSession?.userId = userId;
      await FirebaseServices().saveWorkoutSession(
          userWorkoutProvider.currentWorkoutSession!.toMap(), userId);
      userWorkoutProvider.clearWorkoutSession();
    } catch (e) {
      debugPrint('Error saving workout session: $e');
      throw Exception('Failed to save workout session');
    }
  }

  //This method is called in the SetScreen to add the exercise to the workout session. It takes in the exerciseName and the sets and adds the exercise to the workout session. It also initializes the workout session if it is null.
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

  void resetCurrentExerciseIndex() {
    _currentExerciseIndex = 0;
  }

  void clearWorkoutSession() {
    currentWorkoutSession = null;
    _currentExerciseIndex = 0;
  }

//This function is called in WorkoutScreen to save the current daily workout to Firebase. It replaces the exisiting workout for the selected group.
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

//This function is used to update the exerciseIds. It takes in the userExerciseList and updates the exerciseIds based on the order so that the exercises are shown in the same order as they appeared on SetScreen Listview
  void updateExerciseIds(List<WorkoutGroups> userExerciseList) {
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

  Future<void> fetchUserWorkoutsForAllDates(
      String userId, String workoutGroup, String exerciseName) async {
    List<WorkoutSession> dailyWorkoutsByDate = [];
    debugPrint('UserId for fetchUserWorkoutsForAllDates is: $userId');
    debugPrint(
        'Selected workout group for fetchUserWorkoutsForAllDates is: $workoutGroup');
    debugPrint(
        'Current exercise name for fetchUserWorkoutsForAllDates is: $exerciseName');

    try {
      dailyWorkoutsByDate = await FirebaseServices()
          .fetchUserWorkoutsForAllDate(userId, workoutGroup, exerciseName);
    } catch (e) {
      debugPrint('Error fetching user workouts by date: $e');
      throw Exception('Error fetching user workouts by date: $e');
    }
    _dailyWorkoutsByDate = dailyWorkoutsByDate;
    notifyListeners();
  }

  // Method to get sorted daily workouts by date
  List<WorkoutSession> getSortedDailyWorkoutsByDate() {
    // Clone the list to avoid modifying the original list
    List<WorkoutSession> sortedList =
        List<WorkoutSession>.from(_dailyWorkoutsByDate);

    // Sort the cloned list by date in descending order
    sortedList.sort((a, b) => b.date.compareTo(a.date));

    return sortedList;
  }

//This function fetches the document that exists for the user from the collection user_workout_list. It takes in the userId and fetches the userWorkoutGroups for that userId. It then sets the userExerciseList to the userWorkoutGroups for the selected group. This list is used in the WorkoutScreen to create the exercises for the selected group that will be used in SetScreen.
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

//this function is used in the AddWorkoutScreen to add the exercise to the selected group. It takes in the exercise and adds the exercise to the selected group. It returns true if the exercise is added successfully and false if the exercise already exists in the group.
  bool addExerciseToSelectedGroup(AllExercises exercise) {
    // Attempt to find the group detail for the currently selected group.
    var selectedExerciseDetails = _userExerciseList.firstWhereOrNull(
        (exercise) => exercise.group == _selectedWorkoutGroup);

    // If no detail exists for the selected group, create a new one.
    if (selectedExerciseDetails == null) {
      selectedExerciseDetails =
          WorkoutGroups(group: _selectedWorkoutGroup, exercises: []);
      _userExerciseList.add(selectedExerciseDetails);
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
