import 'package:get_fit/models/user_exercises.dart';

class UserWorkoutModel {
  final String userId;
  final List<WorkoutGroups> exerciseList;

  UserWorkoutModel({
    required this.userId,
    required this.exerciseList,
  });

  factory UserWorkoutModel.fromMap(Map<String, dynamic> map) {
    var workoutGroupList = map['workoutGroups'] as List? ?? [];

    List<WorkoutGroups> userExerciseList = workoutGroupList.map((item) {
      return WorkoutGroups.fromMap(item as Map<String, dynamic>);
    }).toList();

    return UserWorkoutModel(
      userId: map['userId'] ?? '',
      exerciseList: userExerciseList,
    );
  }
}
