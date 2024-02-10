import 'package:flutter/material.dart';
import 'package:get_fit/models/workout_model.dart';

class UserWorkoutModel {
  final String userId;
  final List<WorkoutDetail> workouts;

  UserWorkoutModel({required this.userId, required this.workouts});

factory UserWorkoutModel.fromMap(Map<String, dynamic> map) {
    var workoutList = map['workouts'] as List? ?? []; // Safely handle null
    List<WorkoutDetail> workoutDetails = workoutList.map((item) {
      return WorkoutDetail.fromMap(item as Map<String, dynamic>);
    }).toList();

    return UserWorkoutModel(
      userId: map['userId'] ?? '',
      workouts: workoutDetails,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'workouts': workouts.map((x) => x.toMap()).toList(),
    };
  }
}

class WorkoutDetail {
  final String group;
  final String name;
  final String id;
  List<ExerciseSummary> exercises;

  WorkoutDetail({
    required this.group,
    required this.name,
    this.exercises = const [],
  }) : id = UniqueKey().toString();

factory WorkoutDetail.fromMap(Map<dynamic, dynamic> map) {
    // Ensure exercises is handled safely if null
    List<dynamic> exercisesMapList = map['exercises'] as List? ?? [];
    List<ExerciseSummary> exercises = exercisesMapList.map((item) {
      return ExerciseSummary.fromMap(item as Map<String, dynamic>);
    }).toList();

    return WorkoutDetail(
      group: map['group'] ?? '',
      name: map['name'] ?? '',
      exercises: exercises,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'group': group,
      'name': name,
      'exercises': exercises.map((x) => x.toMap()).toList(),
    };
  }
}
