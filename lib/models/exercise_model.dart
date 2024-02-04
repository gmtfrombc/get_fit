class ExerciseModel {
  final String name;
  final String description;
  final String image;


  ExerciseModel({
    required this.name,
    required this.description,
    required this.image,

  });

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      name: map['name'],
      description: map['description'],
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
    };
  }

}
