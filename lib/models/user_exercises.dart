import 'package:get_fit/models/all_exercises.dart';

class UserExercises {
  final String group;
  List<AllExercises> exercises;

  UserExercises({
    required this.group,
    required this.exercises,
  });

  factory UserExercises.fromMap(Map<dynamic, dynamic> map) {
    // Ensure exercises is handled safely if null
    List<dynamic> exercisesMapList = map['exercises'] as List? ?? [];
    List<AllExercises> exercises = exercisesMapList.map((item) {
      return AllExercises.fromMap(item as Map<String, dynamic>);
    }).toList();

    return UserExercises(
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
