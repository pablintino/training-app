class Exercise {
  final String? name;
  final String? description;
  final int? id;

  Exercise({this.id, this.name, this.description});

  Exercise.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'];

  Map toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };

  @override
  bool operator ==(Object other) => other is Exercise && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
