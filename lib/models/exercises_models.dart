import 'package:equatable/equatable.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/networking/entities/exercise_dto.dart';

class Exercise extends Equatable {
  final String? name;
  final String? description;
  final int? id;

  Exercise({this.id, this.name, this.description});

  Exercise.fromDto(ExerciseDto dto)
      : id = dto.id,
        name = dto.name,
        description = dto.description;

  Exercise.fromModel(ExerciseM model)
      : id = model.id,
        name = model.name,
        description = model.description;

  @override
  List<Object?> get props => [name, description, id];
}
