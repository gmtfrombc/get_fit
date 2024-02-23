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
      // for (var doc in querySnapshot.docs) {
      //   debugPrint('Workout data from firestore: ${doc.data()}');
      // }
      return querySnapshot.docs.map((doc) {
        return WorkoutModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching workouts: $e');
    }
  }

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
      // debugPrint(
      //     'User workout groups: ${userWorkoutGroups[0].exerciseList[0].group}');
      return userWorkoutGroups;
    } catch (e) {
      throw Exception('Error fetching user workout groups: $e');
    }
  }

  Future<void> saveWorkoutSession(
      Map<String, dynamic> workoutSessionData, String userId) async {
    try {
      // Optionally, you can decide to use a specific document ID if necessary
      // For instance, using the userId and the date to create a unique ID for the document
      // String docId = '$userId_${DateTime.now().toIso8601String()}';
      // final docRef = _firestore.collection('workout_sessions').doc(docId);

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
      List<UserExercises> workoutGroups, String selectedGroup) async {
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
}
