class Student {
  final int? id;       
  final String name;
  final String email;
   final int? age;  //  nullable
  final String? course; // nullable

  Student({
    this.id,
    required this.name,
    required this.email,
    this.age,
    this.course,
  });

  // Convert Student object into a Map (for inserting into SQLite)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'age': age,
      'course': course,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Create a Student object from a Map (retrieving from SQLite)
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      age: map['age'] as int,
      course: map['course'] as String,
    );
  }

  // copyWith method (for updates)
  Student copyWith({
    int? id,
    String? name,
    String? email,
    int? age,
    String? course,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      course: course ?? this.course,
    );
  }

  @override
  String toString() {
    return 'Student{id: $id, name: $name, email: $email, age: $age, course: $course}';
  }
}
