class AllExercises {
  int exerciseId;
  final String name;
  final int defaultReps;
  final int defaultSets;
  int? weight;

  AllExercises({
    required this.exerciseId,
    required this.name,
    required this.defaultReps,
    required this.defaultSets,
    this.weight,
  });

  factory AllExercises.fromMap(Map<String, dynamic> map) {
    return AllExercises(
      exerciseId: map['exerciseId'] ?? 0,
      name: map['name'] ?? 'No Name',
      defaultReps: map['defaultReps'] ?? 0,
      defaultSets: map['defaultSets'] ?? 0,
      weight: map['weight'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'defaultReps': defaultReps,
      'defaultSets': defaultSets,
      'weight': weight,
    };
  }
}
