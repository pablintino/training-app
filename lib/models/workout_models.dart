import 'package:equatable/equatable.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/database/join_entities.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/networking/entities/workout_dtos.dart';

abstract class AbstractSequentiable extends Equatable {
  final int? sequence;

  AbstractSequentiable({this.sequence});

  @override
  List<Object?> get props => [sequence];
}

class Workout extends Equatable {
  final String? name;
  final String? description;
  final int? id;
  final List<WorkoutSession> sessions;

  Workout({this.id, this.name, this.description, this.sessions = const []});

  Workout.fromModel(WorkoutM workout)
      : id = workout.id,
        name = workout.name,
        description = workout.description,
        sessions = [];

  Workout.fromJoinedModel(JoinedWorkoutM joinedModel)
      : id = joinedModel.workout.id,
        name = joinedModel.workout.name,
        description = joinedModel.workout.description,
        sessions = joinedModel.sessions
            .map((session) => WorkoutSession.fromJoinedModel(session))
            .toList();

  Workout.fromDto(WorkoutDto dto)
      : id = dto.id,
        name = dto.name,
        description = dto.description,
        sessions = dto.sessions
            .map((session) => WorkoutSession.fromDto(session))
            .toList();

  @override
  List<Object?> get props => [name, description, id, sessions];
}

class WorkoutSession extends Equatable {
  final int? week;
  final int? weekDay;
  final int? id;
  final List<WorkoutPhase> phases;

  WorkoutSession({this.id, this.week, this.weekDay, this.phases = const []});

  WorkoutSession.fromJoinedModel(JoinedWorkoutSessionM joinedModel)
      : id = joinedModel.session.id,
        week = joinedModel.session.week,
        weekDay = joinedModel.session.weekDay,
        phases = joinedModel.phases
            .map((phase) => WorkoutPhase.fromJoinedModel(phase))
            .toList();

  WorkoutSession.fromModel(WorkoutSessionM session)
      : id = session.id,
        week = session.week,
        weekDay = session.weekDay,
        phases = [];

  WorkoutSession.fromDto(WorkoutSessionDto dto)
      : id = dto.id,
        week = dto.week,
        weekDay = dto.weekDay,
        phases =
            dto.phases.map((phase) => WorkoutPhase.fromDto(phase)).toList();

  WorkoutSession copyWith(
      {int? id, int? week, int? weekDay, List<WorkoutPhase>? phases}) {
    return WorkoutSession(
      id: id ?? this.id,
      week: week ?? this.week,
      weekDay: weekDay ?? this.weekDay,
      phases: phases ?? this.phases,
    );
  }

  @override
  List<Object?> get props => [weekDay, week, id, phases];
}

class WorkoutPhase extends AbstractSequentiable {
  final String? name;
  final int? id;
  final List<WorkoutItem> items;

  WorkoutPhase({this.id, this.name, int? sequence, this.items = const []})
      : super(sequence: sequence);

  WorkoutPhase.fromJoinedModel(JoinedWorkoutPhaseM joinedModel)
      : id = joinedModel.phase.id,
        name = joinedModel.phase.name,
        items = joinedModel.items
            .map((item) => WorkoutItem.fromJoinedModel(item))
            .toList(),
        super(sequence: joinedModel.phase.sequence);

  WorkoutPhase.fromDto(WorkoutPhaseDto dto)
      : id = dto.id,
        name = dto.name,
        items = dto.items.map((item) => WorkoutItem.fromDto(item)).toList(),
        super(sequence: dto.sequence);

  WorkoutPhase copyWith(
      {int? id, String? name, int? sequence, List<WorkoutItem>? items}) {
    return WorkoutPhase(
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [name, sequence, id, items, ...super.props];
}

class WorkoutItem extends AbstractSequentiable {
  final String? name;
  final int? rounds;
  final int? restTimeSecs;
  final int? timeCapSecs;
  final int? workTimeSecs;
  final String? workModality;
  final int? id;
  final List<WorkoutSet> sets;

  WorkoutItem(
      {this.rounds,
      this.restTimeSecs,
      this.timeCapSecs,
      this.workTimeSecs,
      this.workModality,
      this.id,
      this.name,
      int? sequence,
      this.sets = const []})
      : super(sequence: sequence);

  WorkoutItem.fromJoinedModel(JoinedWorkoutItemM joinedModel)
      : id = joinedModel.item.id,
        name = joinedModel.item.name,
        rounds = joinedModel.item.rounds,
        workTimeSecs = joinedModel.item.workTimeSecs,
        workModality = joinedModel.item.workModality,
        restTimeSecs = joinedModel.item.restTimeSecs,
        timeCapSecs = joinedModel.item.timeCapSecs,
        sets = joinedModel.sets
            .map((set) => WorkoutSet.fromJoinedModel(set))
            .toList(),
        super(sequence: joinedModel.item.sequence);

  WorkoutItem.fromDto(WorkoutItemDto dto)
      : id = dto.id,
        name = dto.name,
        rounds = dto.rounds,
        workTimeSecs = dto.workTimeSecs,
        workModality = dto.workModality,
        restTimeSecs = dto.restTimeSecs,
        timeCapSecs = dto.timeCapSecs,
        sets = dto.sets.map((set) => WorkoutSet.fromDto(set)).toList(),
        super(sequence: dto.sequence);

  @override
  List<Object?> get props => [
        name,
        id,
        rounds,
        restTimeSecs,
        timeCapSecs,
        workTimeSecs,
        workModality,
        sets,
        ...super.props
      ];
}

class WorkoutSet extends AbstractSequentiable {
  final int? reps;
  final int? distance;
  final double? weight;
  final int? setExecutions;
  final int? id;
  final int? exerciseId;
  final Exercise? exercise;

  WorkoutSet(
      {this.reps,
      this.distance,
      this.weight,
      this.setExecutions,
      int? sequence,
      this.id,
      this.exerciseId,
      this.exercise});

  WorkoutSet.fromJoinedModel(JoinedWorkoutSetM joinedModel)
      : id = joinedModel.set.id,
        reps = joinedModel.set.reps,
        weight = joinedModel.set.weight,
        distance = joinedModel.set.distance,
        setExecutions = joinedModel.set.setExecutions,
        exerciseId = joinedModel.exercise.id,
        exercise = Exercise.fromModel(joinedModel.exercise),
        super(sequence: joinedModel.set.sequence);

  WorkoutSet.fromDto(WorkoutSetDto dto)
      : id = dto.id,
        reps = dto.reps,
        weight = dto.weight,
        distance = dto.distance,
        setExecutions = dto.setExecutions,
        exerciseId = dto.exerciseId,
        exercise = null,
        super(sequence: dto.sequence);

  @override
  List<Object?> get props => [
        reps,
        id,
        distance,
        weight,
        exerciseId,
        exercise,
        setExecutions,
        ...super.props
      ];
}
