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
  List<AllExercises> _newWorkoutExercises = [];
List<WorkoutGroups> _userWorkoutGroupsForHomeScreen = [];


  List<WorkoutSession> get dailyWorkoutsByDate => _dailyWorkoutsByDate;

  List<AllExercises> get newWorkoutExercises => _newWorkoutExercises;

  List<WorkoutGroups> get userWorkoutGroupsForHomeScreen =>
      _userWorkoutGroupsForHomeScreen;

  int _currentExerciseIndex = 0;

  int get currentExerciseIndex => _currentExerciseIndex;

  String _selectedWorkoutGroup = '';

  String get selectedWorkoutGroup => _selectedWorkoutGroup;

  final int _currentGroupIndex = 0; // Default to the first group

  int get currentGroupIndex => _currentGroupIndex;

  bool get isLastExercise =>
      currentExerciseIndex == exercisesForSelectedWorkoutGroup.length - 1;

  final List<WorkoutGroups> _userExerciseList = [];

  List<WorkoutGroups> get userExerciseList => _userExerciseList;

  Future<void> fetchUserWorkoutGroupsForHomeScreen(String userId) async {
    FirebaseServices services = FirebaseServices();
    List<Map<String, dynamic>> fetchedHomeScreenGroups =
        await services.fetchUserWorkoutGroupsForHomeScreen(userId);

    _userWorkoutGroupsForHomeScreen = fetchedHomeScreenGroups
        .map((group) => WorkoutGroups.fromMap(group))
        .toList();

    notifyListeners();
  }

  void removeExerciseFromNewWorkout(AllExercises exercise) {
    _newWorkoutExercises.remove(exercise);
    notifyListeners();
  }

  // Reset the list when the workout is saved or canceled
  void resetNewWorkoutExercises() {
    _newWorkoutExercises = [];
    notifyListeners();
  }

  bool isExerciseInNewWorkout(AllExercises exercise) {
    return newWorkoutExercises.any((ex) => ex.name == exercise.name);
  }

  void addExercisesToNewWorkout(List<AllExercises> exercises) {
    for (var exercise in exercises) {
      if (!isExerciseInNewWorkout(exercise)) {
        newWorkoutExercises.add(exercise);
      }
    }
    notifyListeners();
  }

//This function is called in WorkoutScreen before navigating to SetScreen. It first creates a list of exercises that will be shown in the SetScreen listivew, and then it creates the _dailyExerciseByDate list which is all of the previous exercises the user has performeed for the selected group.
  Future<void> fetchAndCacheWorkoutData(
      String workoutGroup, String userId) async {
//fetch the list of workoutGroups in user_workout_list (workout group and list of exercises). This creates the list _userExerciseList and is used in SetScreen to present the exercises for the selected group in the ListView.
    await fetchUserWorkoutGroups(userId);
    //create list _dailyWorkoutsByDate. This list containes all of the previous workout data for the selected group, including the daily workout list, userId, workoutGroup, and date.
    _dailyWorkoutsByDate = await FirebaseServices()
        .fetchUserWorkoutsForGroup(userId, workoutGroup);
    notifyListeners();
  }

//as above; fetch the list of workoutGroups in user_workout_list (workout group and list of exercises), based on the workoutGroup selected in HomeScreen grid (e.g. Strength/Endurance). This creates the list _userExerciseList
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
      notifyListeners();
    }
  }

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
    // String selectedExercise =
    //     exercisesForSelectedWorkoutGroup[_currentExerciseIndex].name;
    // debugPrint('Selected exercise for NEXT exercise is: $selectedExercise');
    // fetchUserWorkoutsForAllDates(
    //     userId!, selectedWorkoutGroup, selectedExercise);
    // notifyListeners();
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

  List<WorkoutSession> getSortedWorkoutsByExercise(String currentExercise) {
    List<WorkoutSession> filteredAndTransformedList = _dailyWorkoutsByDate
        .map((session) {
          // Filter the dailyWorkout list to include only workouts for the currentExercise
          List<UserWorkouts> filteredDailyWorkout = session.dailyWorkout
              .where((workout) => workout.exerciseName == currentExercise)
              .toList();

          // Return a new WorkoutSession with the filtered dailyWorkout list
          return WorkoutSession(
            date: session.date,
            workoutGroup: session.workoutGroup,
            userId: session.userId,
            dailyWorkout: filteredDailyWorkout,
          );
        })
        .where((session) => session.dailyWorkout.isNotEmpty)
        .toList(); // Keep only sessions that have the current exercise

    // Sort the transformed list by date in descending order
    filteredAndTransformedList.sort((a, b) => b.date.compareTo(a.date));

    return filteredAndTransformedList;
  }

// Refactored method in UserWorkoutProvider to handle batch additions and check for duplicates.
  void addExercisesToWorkout(context, List<AllExercises> exercisesToAdd,
      {bool isNewWorkout = false}) {
    List<AllExercises> targetList;
    final userWorkoutProvider =
        Provider.of<UserWorkoutProvider>(context, listen: false);

    if (isNewWorkout) {
      targetList = _newWorkoutExercises;
    } else {
      targetList = userWorkoutProvider.exercisesForSelectedWorkoutGroup;
    }

    for (var exercise in exercisesToAdd) {
      // Avoid adding duplicate exercises
      if (!targetList
          .any((existingExercise) => existingExercise.name == exercise.name)) {
        targetList.add(exercise);
      }
    }

    notifyListeners();
  }

  Future<void> addNewWorkoutGroup(String userId, String workoutName,
      List<AllExercises> newExerciseList) async {
    debugPrint('Adding new workout group: $workoutName for user: $userId');
    try {
      // Convert exercises list to a list of maps
      List<Map<String, dynamic>> serializedExercises =
          newExerciseList.map((exercise) => exercise.toMap()).toList();

      // Create the new workout group map
      Map<String, dynamic> newWorkoutGroup = {
        'group': workoutName,
        'exercises': serializedExercises,
      };

      // Call Firebase function to save the new workout group
      await FirebaseServices().addUserWorkoutGroup(userId, newWorkoutGroup);
    } catch (e) {
      throw Exception('Error adding new workout group: $e');
    }
  }
}
