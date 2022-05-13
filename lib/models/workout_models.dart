import 'package:equatable/equatable.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/database/join_entities.dart';
import 'package:training_app/models/exercises_models.dart';

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

  @override
  List<Object?> get props => [weekDay, week, id, phases];
}

class WorkoutPhase extends Equatable {
  final String? name;
  final int? sequence;
  final int? id;
  final List<WorkoutItem> items;

  WorkoutPhase({this.id, this.name, this.sequence, this.items = const []});

  WorkoutPhase.fromJoinedModel(JoinedWorkoutPhaseM joinedModel)
      : id = joinedModel.phase.id,
        name = joinedModel.phase.name,
        sequence = joinedModel.phase.sequence,
        items = joinedModel.items
            .map((item) => WorkoutItem.fromJoinedModel(item))
            .toList();

  @override
  List<Object?> get props => [name, sequence, id, items];
}

class WorkoutItem extends Equatable {
  final String? name;
  final int? sequence;
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
      this.sequence,
      this.sets = const []});

  WorkoutItem.fromJoinedModel(JoinedWorkoutItemM joinedModel)
      : id = joinedModel.item.id,
        name = joinedModel.item.name,
        sequence = joinedModel.item.sequence,
        rounds = joinedModel.item.rounds,
        workTimeSecs = joinedModel.item.workTimeSecs,
        workModality = joinedModel.item.workModality,
        restTimeSecs = joinedModel.item.restTimeSecs,
        timeCapSecs = joinedModel.item.timeCapSecs,
        sets = joinedModel.sets
            .map((set) => WorkoutSet.fromJoinedModel(set))
            .toList();

  @override
  List<Object?> get props => [
        name,
        sequence,
        id,
        rounds,
        restTimeSecs,
        timeCapSecs,
        workTimeSecs,
        workModality,
        sets
      ];
}

class WorkoutSet extends Equatable {
  final int? reps;
  final int? distance;
  final double? weight;
  final int? setExecutions;
  final int? sequence;
  final int? id;
  final int? exerciseId;
  final Exercise? exercise;

  WorkoutSet(
      {this.reps,
      this.distance,
      this.weight,
      this.setExecutions,
      this.sequence,
      this.id,
      this.exerciseId,
      this.exercise});

  WorkoutSet.fromJoinedModel(JoinedWorkoutSetM joinedModel)
      : id = joinedModel.set.id,
        sequence = joinedModel.set.sequence,
        reps = joinedModel.set.reps,
        weight = joinedModel.set.weight,
        distance = joinedModel.set.distance,
        setExecutions = joinedModel.set.setExecutions,
        exerciseId = joinedModel.exercise.id,
        exercise = Exercise.fromModel(joinedModel.exercise);

  @override
  List<Object?> get props => [
        reps,
        sequence,
        id,
        distance,
        weight,
        exerciseId,
        exercise,
        setExecutions
      ];
}
