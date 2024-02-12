import 'package:get_fit/models/workout_model.dart';

class UserWorkoutModel {
  final String userId;
  final List<ExerciseDetails> workoutGroups;

  UserWorkoutModel({required this.userId, required this.workoutGroups});

  factory UserWorkoutModel.fromMap(Map<String, dynamic> map) {
    var workoutGroupList = map['workoutGroups'] as List? ?? [];

    List<ExerciseDetails> workoutGroupDetails = workoutGroupList.map((item) {
      return ExerciseDetails.fromMap(item as Map<String, dynamic>);
    }).toList();

    return UserWorkoutModel(
      userId: map['userId'] ?? '',
      workoutGroups: workoutGroupDetails,
    );
  }
}

class ExerciseDetails {
  final String group;
  List<ExerciseSummary> exercises;

  ExerciseDetails({
    required this.group,
    required this.exercises,
  });

  factory ExerciseDetails.fromMap(Map<dynamic, dynamic> map) {
    // Ensure exercises is handled safely if null
    List<dynamic> exercisesMapList = map['exercises'] as List? ?? [];
    List<ExerciseSummary> exercises = exercisesMapList.map((item) {
      return ExerciseSummary.fromMap(item as Map<String, dynamic>);
    }).toList();

    return ExerciseDetails(
      group: map['group'] ?? '',
      exercises: exercises,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'group': group,
      'exercises': exercises.map((x) => x.toMap()).toList(),
    };
  }
}
