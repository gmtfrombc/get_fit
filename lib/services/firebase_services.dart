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
}
