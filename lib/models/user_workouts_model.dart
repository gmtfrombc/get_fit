import 'package:flutter/material.dart';

class UserWorkoutModel {
  final String userId;
  final List<WorkoutDetail> workouts;

  UserWorkoutModel({required this.userId, required this.workouts});

  factory UserWorkoutModel.fromMap(Map<String, dynamic> map) {
    var workoutList = map['workouts'] as List;
    List<WorkoutDetail> workoutDetails =
        workoutList.map((item) => WorkoutDetail.fromMap(item)).toList();

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
  final String id = UniqueKey().toString();

  WorkoutDetail({required this.group, required this.name});

  factory WorkoutDetail.fromMap(Map<dynamic, dynamic> map) {
    return WorkoutDetail(
      group: map['group'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'group': group,
      'name': name,
    };
  }
}

