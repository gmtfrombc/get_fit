class WorkoutSession {
  final DateTime date;
  final String workoutGroup;
  String userId;
  final List<UserWorkouts> dailyWorkout;

  WorkoutSession({
    required this.date,
    required this.workoutGroup,
    required this.userId,
    required this.dailyWorkout,
  });

  factory WorkoutSession.fromMap(Map<dynamic, dynamic> map) {
    List<dynamic> dailyWorkoutMapList = map['dailyWorkout'] as List? ?? [];
    List<UserWorkouts> dailyWorkout = dailyWorkoutMapList.map((item) {
      return UserWorkouts.fromMap(item as Map<String, dynamic>);
    }).toList();

    return WorkoutSession(
      date: map['date'] ?? DateTime.now(),
      workoutGroup: map['workoutGroup'] ?? '',
      userId: map['userId'] ?? '',
      dailyWorkout: dailyWorkout,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'workoutGroup': workoutGroup,
      'userId': userId,
      'dailyWorkout': dailyWorkout.map((x) => x.toMap()).toList(),
    };
  }
}

class UserWorkouts {
  final String exerciseName;
  final List<Sets> sets;

  UserWorkouts({

    required this.exerciseName,
    required this.sets,
  });

  factory UserWorkouts.fromMap(Map<dynamic, dynamic> map) {
    // Ensure sets is handled safely if null
    List<dynamic> setsMapList = map['sets'] as List? ?? [];
    List<Sets> sets = setsMapList.map((item) {
      return Sets.fromMap(item as Map<String, dynamic>);
    }).toList();

    return UserWorkouts(

      exerciseName: map['exerciseName'] ?? '',
      sets: sets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'sets': sets.map((x) => x.toMap()).toList(),
    };
  }
}

class Sets {
  final int reps;
  final int weight;
  final String setNumber;

  Sets({
    required this.reps,
    required this.weight,
    required this.setNumber,
  });

  factory Sets.fromMap(Map<dynamic, dynamic> map) {
    return Sets(
      reps: map['reps'] ?? 0,
      weight: map['weight'] ?? 0,
      setNumber: map['setNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reps': reps,
      'weight': weight,
      'setNumber': setNumber,
    };
  }
}
