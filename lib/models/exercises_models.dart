class Exercise {
  String? name;
  String? description;
  int? id;

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
}
