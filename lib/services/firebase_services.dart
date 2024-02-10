import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_fit/models/user_workouts_model.dart';
import 'package:get_fit/models/workout_model.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Workout>> fetchWorkouts() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('workouts').get();
      return querySnapshot.docs.map((doc) {
        return Workout.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching workouts: $e');
    }
  }

  Future<List<Workout>> fetchWorkoutsByGroup(String group) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('workouts')
          .where('group', isEqualTo: group)
          .get();
      return querySnapshot.docs.map((doc) {
        return Workout.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching workouts by group: $e');
    }
  }

  Future<List<UserWorkoutModel>> fetchUserWorkouts(
      String userId, String group) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('user_workout_list')
          .where('userId', isEqualTo: userId)
          //.where('workouts', isEqualTo: group)
          .get();
      return querySnapshot.docs
          .map((doc) =>
              UserWorkoutModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching user workouts: $e');
    }
  }

  Future<void> saveUserWorkouts(
      String userId, List<WorkoutDetail> workoutDetails) async {
    try {
      // Serialize workout details including exercises
      List<Map<String, dynamic>> serializedWorkouts =
          workoutDetails.map((workoutDetail) {
        List<Map<String, dynamic>> serializedExercises =
            workoutDetail.exercises.map((exercise) {
          return exercise.toMap();
        }).toList();

        return {
          ...workoutDetail
              .toMap(), // Serialize the rest of the workoutDetail fields
          'exercises': serializedExercises, // Add serialized exercises here
        };
      }).toList();

      // Prepare the document data
      Map<String, dynamic> userWorkoutData = {
        'userId': userId,
        'workouts': serializedWorkouts,
      };

      // Update Firestore
      await _firestore
          .collection('user_workout_list')
          .doc(userId)
          .set(userWorkoutData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error saving user workouts: $e');
    }
  }
}
