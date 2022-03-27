import 'package:equatable/equatable.dart';

class Workout extends Equatable {
  final String? name;
  final String? description;
  final int? id;

  Workout({this.id, this.name, this.description});

  Workout.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'];

  Map toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };

  @override
  List<Object?> get props => [name, description, id];
}
