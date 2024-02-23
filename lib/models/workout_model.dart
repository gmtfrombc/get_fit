import 'package:get_fit/models/all_exercises.dart';

class WorkoutModel {
  final String group;
  String? image;
  String? color;
  final List<AllExercises> exercises;

  WorkoutModel({
    required this.group,
    this.image,
    this.color,
    required this.exercises,
  });

  factory WorkoutModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutModel(
      //id: id,
      group: map['group'] ?? '',
      image: map['image'] ?? '',
      color: map['color'] ?? '',
      exercises: map['exercise'] != null
          ? List<AllExercises>.from(
              (map['exercise'] as List).map(
                (x) => AllExercises.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [], // Handle null case
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': group,
      'image': image,
      'exercises': exercises.map((x) => x.toMap()).toList(),
    };
  }
}
