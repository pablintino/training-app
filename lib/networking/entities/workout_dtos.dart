import 'package:json_annotation/json_annotation.dart';

part 'workout_dtos.g.dart';

@JsonSerializable()
class WorkoutDto {
  final String? name;
  final String? description;
  final int? id;
  final List<WorkoutSessionDto> sessions;

  WorkoutDto({this.id, this.name, this.description, this.sessions = const []});

  factory WorkoutDto.fromJson(Map<String, dynamic> json) =>
      _$WorkoutDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutDtoToJson(this);
}

@JsonSerializable()
class WorkoutSessionDto {
  final int? week;
  final int? weekDay;
  final int? id;
  final List<WorkoutPhaseDto> phases;

  WorkoutSessionDto({this.id, this.week, this.weekDay, this.phases = const []});

  factory WorkoutSessionDto.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSessionDtoToJson(this);
}

@JsonSerializable()
class WorkoutPhaseDto {
  final String? name;
  final int? sequence;
  final int? id;
  final List<WorkoutItemDto> items;

  WorkoutPhaseDto({this.id, this.name, this.sequence, this.items = const []});

  factory WorkoutPhaseDto.fromJson(Map<String, dynamic> json) =>
      _$WorkoutPhaseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutPhaseDtoToJson(this);
}

@JsonSerializable()
class WorkoutItemDto {
  final String? name;
  final int? sequence;
  final int? rounds;
  final int? restTimeSecs;
  final int? timeCapSecs;
  final int? workTimeSecs;
  final String? workModality;
  final int? id;
  final List<WorkoutSetDto> sets;

  WorkoutItemDto(
      {this.rounds,
      this.restTimeSecs,
      this.timeCapSecs,
      this.workTimeSecs,
      this.workModality,
      this.id,
      this.name,
      this.sequence,
      this.sets = const []});

  factory WorkoutItemDto.fromJson(Map<String, dynamic> json) =>
      _$WorkoutItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutItemDtoToJson(this);
}

@JsonSerializable()
class WorkoutSetDto {
  final int? reps;
  final int? distance;
  final double? weight;
  final int? setExecutions;
  final int? sequence;
  final int? id;
  final int? exerciseId;

  WorkoutSetDto(
      {this.reps,
      this.distance,
      this.weight,
      this.setExecutions,
      this.sequence,
      this.id,
      this.exerciseId});

  factory WorkoutSetDto.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSetDtoToJson(this);
}
