import 'package:get_fit/models/user_exercises.dart';

class UserWorkoutModel {
  final String userId;
  final List<UserExercises> exerciseList;

  UserWorkoutModel({
    required this.userId,
    required this.exerciseList,
  });

  factory UserWorkoutModel.fromMap(Map<String, dynamic> map) {
    var workoutGroupList = map['workoutGroups'] as List? ?? [];

    List<UserExercises> userExerciseList = workoutGroupList.map((item) {
      return UserExercises.fromMap(item as Map<String, dynamic>);
    }).toList();

    return UserWorkoutModel(
      userId: map['userId'] ?? '',
      exerciseList: userExerciseList,
    );
  }
}
