class WorkoutModel {
  final String group;
  String? image;
  String? color;
  final List<ExerciseSummary> exercises;

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
          ? List<ExerciseSummary>.from(
              (map['exercise'] as List).map(
                (x) => ExerciseSummary.fromMap(x as Map<String, dynamic>),
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

class ExerciseSummary {
  int exerciseId;
  final String name;
  final int defaultReps;
  final int defaultSets;

  ExerciseSummary({
    required this.exerciseId,
    required this.name,
    required this.defaultReps,
    required this.defaultSets,
  });

  factory ExerciseSummary.fromMap(Map<String, dynamic> map) {
    return ExerciseSummary(
      exerciseId: map['exerciseId'] ?? 0,
      name: map['name'] ?? 'No Name',
      defaultReps: map['defaultReps'] ?? 0,
      defaultSets: map['defaultSets'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'defaultReps': defaultReps,
      'defaultSets': defaultSets,
    };
  }
}
