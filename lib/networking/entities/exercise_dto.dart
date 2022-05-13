import 'package:json_annotation/json_annotation.dart';

part 'exercise_dto.g.dart';

@JsonSerializable()
class ExerciseDto {
  final String? name;
  final String? description;
  final int? id;

  ExerciseDto({this.id, this.name, this.description});

  factory ExerciseDto.fromJson(Map<String, dynamic> json) =>
      _$ExerciseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseDtoToJson(this);
}
