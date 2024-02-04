class Workout {
  //final String id;
  final String group;
  final String image;
  final List<ExerciseSummary> exercises;

  Workout({
    //required this.id,
    required this.group,
    required this.image,
    required this.exercises,
  });

  factory Workout.fromMap(Map<String, dynamic> map, String id) {
    return Workout(
      //id: id,
      group: map['group'] ?? '',
      image: map['image'] ?? '',
      exercises: map['exercise'] != null
          ? List<ExerciseSummary>.from((map['exercise'] as List)
              .map((x) => ExerciseSummary.fromMap(x as Map<String, dynamic>)))
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
  final String exerciseId;
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
      exerciseId: map['exerciseId'] ?? 'No ID',
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
