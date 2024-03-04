import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_fit/models/user_exercises.dart';
import 'package:get_fit/models/user_workout_model.dart';
import 'package:get_fit/models/user_workouts.dart';
import 'package:get_fit/models/workout_model.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<WorkoutModel>> fetchWorkouts() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('workouts').get();

      return querySnapshot.docs.map((doc) {
        return WorkoutModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching workouts: $e');
    }
  }

    Future<List<Map<String, dynamic>>> fetchUserWorkoutGroupsForHomeScreen(
      String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('user_workout_list').doc(userId).get();
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> workoutGroups = data['workoutGroups'] ?? [];
        // Convert each group to a Map<String, dynamic>
        return workoutGroups.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching user workout groups: $e");
      return [];
    }
  }

//fetch the workout sessions from 'user_workouts' based on the workout group. The list that is created becomes _dalyWorkoutsByDate
  Future<List<WorkoutSession>> fetchUserWorkoutsForGroup(
      String userId, String workoutGroup) async {
    Query query = _firestore
        .collection('user_workouts')
        .where('userId', isEqualTo: userId)
        .where('workoutGroup', isEqualTo: workoutGroup);

    try {
      QuerySnapshot querySnapshot = await query.get();
      List<WorkoutSession> workoutSessions = querySnapshot.docs.map((doc) {
        // Assuming you have a WorkoutSession model with a fromMap constructor
        // debugPrint('Workout data from firestore: ${doc.data().toString()}');
        return WorkoutSession.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return workoutSessions;
    } catch (e) {
      throw Exception(
          'Error fetching workout sessions for group $workoutGroup: $e');
    }
  }

//fetches all the workouts for the AddWorkoutScreen.
  Future<List<WorkoutModel>> fetchWorkoutsByGroup(String group) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('workouts')
          .where('group', isEqualTo: group)
          .get();
      return querySnapshot.docs.map((doc) {
        return WorkoutModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching workouts by group: $e');
    }
  }

  //return the list of workoutGroups in user_workout_list. Will include the workout group (strength/endurance) and the list of exercises (name, defaultReps, defaultSets, weight). It is called from fetchUserWorkoutGroups to set _userExerciseList.
  Future<List<UserWorkoutModel>> fetchUserWorkoutGroups(String userId,
      {String? group}) async {
    Query query = _firestore
        .collection('user_workout_list')
        .where('userId', isEqualTo: userId);

    // If a group is specified, you might need to adjust this part depending on your data structure
    if (group != null) {
      query = query.where('workoutGroups.groupName',
          isEqualTo:
              group); // This line is pseudo-code and might not directly work depending on your Firestore structure
    }

    try {
      QuerySnapshot querySnapshot = await query.get();
      List<UserWorkoutModel> userWorkoutGroups = querySnapshot.docs.map((doc) {
        return UserWorkoutModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return userWorkoutGroups;
    } catch (e) {
      throw Exception('Error fetching user workout groups: $e');
    }
  }

  Future<void> saveWorkoutSession(
      Map<String, dynamic> workoutSessionData, String userId) async {
    try {
      final docRef =
          _firestore.collection('user_workouts').doc(); // Create a new document
      await docRef.set(workoutSessionData);
    } catch (e) {
      debugPrint('Error saving workout session: $e');
      throw Exception('Failed to save workout session');
    }
  }

  Future<void> saveUserWorkout(UserWorkouts workout, String userId) async {
    try {
      final docRef =
          _firestore.collection('user_workouts').doc(); // Create a new document
      await docRef.set({
        'userId': userId,
        ...workout.toMap(),
      });
    } catch (e) {
      debugPrint('Error saving workout: $e');
      throw Exception('Failed to save workout');
    }
  }

  Future<void> saveUserGroupWorkouts(String userId,
      List<WorkoutGroups> workoutGroups, String selectedGroup) async {
    try {
      DocumentReference docRef =
          _firestore.collection('user_workout_list').doc(userId);

      // Fetch the existing document for the user
      DocumentSnapshot snapshot = await docRef.get();
      Map<String, dynamic> userData =
          snapshot.exists ? snapshot.data() as Map<String, dynamic> : {};

      // Prepare the new workout group data
      List<Map<String, dynamic>> serializedWorkoutGroups = workoutGroups
          .where((group) => group.group == selectedGroup)
          .map((group) {
        List<Map<String, dynamic>> serializedExercises =
            group.exercises.map((exercise) => exercise.toMap()).toList();
        return {'group': group.group, 'exercises': serializedExercises};
      }).toList();

      // Update only the part of the document for the selected group
      List<dynamic> existingGroups = userData['workoutGroups'] ?? [];
      Map<String, dynamic>? existingGroupData = existingGroups
          .firstWhereOrNull((element) => element['group'] == selectedGroup);

      if (existingGroupData != null) {
        // Update existing group data
        existingGroupData['exercises'] =
            serializedWorkoutGroups.first['exercises'];
      } else {
        // Or add new group data if it doesn't exist
        existingGroups.add(serializedWorkoutGroups.first);
      }

      // Save back the updated document
      await docRef.set({'userId': userId, 'workoutGroups': existingGroups},
          SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error saving user workout groups: $e');
    }
  }

  // Future<List<WorkoutSession>> fetchUserWorkoutsForAllDates(String userId,
  //     String selectedWorkoutGroup, String currentExercise) async {
  //   List<WorkoutSession> dailyWorkoutsByDate = [];

  //   try {
  //     // Fetch documents from 'user_workouts' where 'userId' and 'workoutGroup' match the provided values
  //     QuerySnapshot snapshot = await _firestore
  //         .collection('user_workouts')
  //         .where('userId', isEqualTo: userId)
  //         .where('workoutGroup', isEqualTo: selectedWorkoutGroup)
  //         .get();

  //     for (var doc in snapshot.docs) {
  //       // Convert each document into a WorkoutSession
  //       WorkoutSession session =
  //           WorkoutSession.fromMap(doc.data() as Map<String, dynamic>);

  //       // Filter 'dailyWorkout' list by 'exerciseName'
  //       var filteredDailyWorkout = session.dailyWorkout
  //           .where((workout) => workout.exerciseName == currentExercise)
  //           .toList();

  //       // If there are workouts after filtering, create a new WorkoutSession with the filtered list
  //       if (filteredDailyWorkout.isNotEmpty) {
  //         WorkoutSession filteredSession = WorkoutSession(
  //           date: session.date,
  //           workoutGroup: session.workoutGroup,
  //           userId: session.userId,
  //           dailyWorkout: filteredDailyWorkout,
  //         );

  //         // Add the filtered session to the list
  //         dailyWorkoutsByDate.add(filteredSession);
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Error fetching workouts: $e");
  //   }

  //   return dailyWorkoutsByDate;
  // }

  Future<void> addUserWorkoutGroup(
      String userId, Map<String, dynamic> newWorkoutGroup) async {
    debugPrint(' Adding group in firebase: newWorkoutGroup: $newWorkoutGroup');
    DocumentReference docRef =
        _firestore.collection('user_workout_list').doc(userId);

    // Fetch the existing document for the user
    DocumentSnapshot snapshot = await docRef.get();
    Map<String, dynamic> userData =
        snapshot.exists ? snapshot.data() as Map<String, dynamic> : {};

    // Get existing workout groups or initialize if null
    List<dynamic> existingGroups = userData['workoutGroups'] ?? [];

    // Add the new workout group
    existingGroups.add(newWorkoutGroup);

    // Save back the updated document with the new workout group added
    await docRef.set({'userId': userId, 'workoutGroups': existingGroups},
        SetOptions(merge: true));
  }
}
