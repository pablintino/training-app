// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseDto _$ExerciseDtoFromJson(Map<String, dynamic> json) => ExerciseDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ExerciseDtoToJson(ExerciseDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'id': instance.id,
    };
