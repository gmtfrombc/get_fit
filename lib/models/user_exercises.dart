import 'package:get_fit/models/all_exercises.dart';
//in Firbase WorkoutGroups is a field in the user_workout_list collection. Each document in this collection has a userId and a list of workoutGroups. 
class WorkoutGroups {
  final String group;
  List<AllExercises> exercises;

  WorkoutGroups({
    required this.group,
    required this.exercises,
  });

  factory WorkoutGroups.fromMap(Map<dynamic, dynamic> map) {
    // Ensure exercises is handled safely if null
    List<dynamic> exercisesMapList = map['exercises'] as List? ?? [];
    List<AllExercises> exercises = exercisesMapList.map((item) {
      return AllExercises.fromMap(item as Map<String, dynamic>);
    }).toList();

    return WorkoutGroups(
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
