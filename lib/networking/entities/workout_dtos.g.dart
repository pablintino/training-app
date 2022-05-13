// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutDto _$WorkoutDtoFromJson(Map<String, dynamic> json) => WorkoutDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map(
                  (e) => WorkoutSessionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WorkoutDtoToJson(WorkoutDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'id': instance.id,
      'sessions': instance.sessions,
    };

WorkoutSessionDto _$WorkoutSessionDtoFromJson(Map<String, dynamic> json) =>
    WorkoutSessionDto(
      id: json['id'] as int?,
      week: json['week'] as int?,
      weekDay: json['weekDay'] as int?,
      phases: (json['phases'] as List<dynamic>?)
              ?.map((e) => WorkoutPhaseDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WorkoutSessionDtoToJson(WorkoutSessionDto instance) =>
    <String, dynamic>{
      'week': instance.week,
      'weekDay': instance.weekDay,
      'id': instance.id,
      'phases': instance.phases,
    };

WorkoutPhaseDto _$WorkoutPhaseDtoFromJson(Map<String, dynamic> json) =>
    WorkoutPhaseDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      sequence: json['sequence'] as int?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => WorkoutItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WorkoutPhaseDtoToJson(WorkoutPhaseDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sequence': instance.sequence,
      'id': instance.id,
      'items': instance.items,
    };

WorkoutItemDto _$WorkoutItemDtoFromJson(Map<String, dynamic> json) =>
    WorkoutItemDto(
      rounds: json['rounds'] as int?,
      restTimeSecs: json['restTimeSecs'] as int?,
      timeCapSecs: json['timeCapSecs'] as int?,
      workTimeSecs: json['workTimeSecs'] as int?,
      workModality: json['workModality'] as String?,
      id: json['id'] as int?,
      name: json['name'] as String?,
      sequence: json['sequence'] as int?,
      sets: (json['sets'] as List<dynamic>?)
              ?.map((e) => WorkoutSetDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WorkoutItemDtoToJson(WorkoutItemDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sequence': instance.sequence,
      'rounds': instance.rounds,
      'restTimeSecs': instance.restTimeSecs,
      'timeCapSecs': instance.timeCapSecs,
      'workTimeSecs': instance.workTimeSecs,
      'workModality': instance.workModality,
      'id': instance.id,
      'sets': instance.sets,
    };

WorkoutSetDto _$WorkoutSetDtoFromJson(Map<String, dynamic> json) =>
    WorkoutSetDto(
      reps: json['reps'] as int?,
      distance: json['distance'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      setExecutions: json['setExecutions'] as int?,
      sequence: json['sequence'] as int?,
      id: json['id'] as int?,
      exerciseId: json['exerciseId'] as int?,
    );

Map<String, dynamic> _$WorkoutSetDtoToJson(WorkoutSetDto instance) =>
    <String, dynamic>{
      'reps': instance.reps,
      'distance': instance.distance,
      'weight': instance.weight,
      'setExecutions': instance.setExecutions,
      'sequence': instance.sequence,
      'id': instance.id,
      'exerciseId': instance.exerciseId,
    };
