import 'package:equatable/equatable.dart';
import 'package:training_app/models/exercises_models.dart';

class Workout extends Equatable {
  final String? name;
  final String? description;
  final int? id;
  final List<WorkoutSession> sessions;

  Workout({this.id, this.name, this.description, this.sessions = const []});

  Workout.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        sessions = List<WorkoutSession>.from(
            (json['sessions'] ?? []).map((i) => WorkoutSession.fromJson(i)));

  Map toJson() => {
        'id': id,
        'name': name,
        'description': description,
        // TODO SESSIONS
      };

  @override
  List<Object?> get props => [name, description, id, sessions];
}

class WorkoutSession extends Equatable {
  final int? week;
  final int? weekDay;
  final int? id;
  final List<WorkoutPhase> phases;

  WorkoutSession({this.id, this.week, this.weekDay, this.phases = const []});

  WorkoutSession.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        week = json['week'],
        weekDay = json['weekDay'],
        phases = List<WorkoutPhase>.from(
            (json['phases'] ?? []).map((i) => WorkoutPhase.fromJson(i)));

  Map toJson() => {
        'id': id,
        'weekDay': weekDay,
        'week': week,
        // TODO PHASES
      };

  @override
  List<Object?> get props => [weekDay, week, id, phases];
}

class WorkoutPhase extends Equatable {
  final String? name;
  final int? sequence;
  final int? id;
  final List<WorkoutItem> items;

  WorkoutPhase({this.id, this.name, this.sequence, this.items = const []});

  WorkoutPhase.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        sequence = json['sequence'],
        name = json['name'],
        items = List<WorkoutItem>.from(
            (json['items'] ?? []).map((i) => WorkoutItem.fromJson(i)));

  Map toJson() => {
        'id': id,
        'sequence': sequence,
        'name': name,
        // TODO ITEMS
      };

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

  WorkoutItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        sequence = json['sequence'],
        name = json['name'],
        rounds = json['rounds'],
        restTimeSecs = json['restTimeSecs'],
        timeCapSecs = json['timeCapSecs'],
        workTimeSecs = json['workTimeSecs'],
        workModality = json['workModality'],
        sets = List<WorkoutSet>.from(
            (json['sets'] ?? []).map((i) => WorkoutSet.fromJson(i)));

  Map toJson() => {
        'id': id,
        'sequence': sequence,
        'name': name,
        'rounds': rounds,
        'restTimeSecs': restTimeSecs,
        'timeCapSecs': timeCapSecs,
        'workTimeSecs': workTimeSecs,
        'workModality': workModality,
        // TODO SETS
      };

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

  WorkoutSet(
      {this.reps,
      this.distance,
      this.weight,
      this.setExecutions,
      this.sequence,
      this.id,
      this.exerciseId});

  WorkoutSet.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        sequence = json['sequence'],
        reps = json['reps'],
        distance = json['distance'],
        weight = json['weight'],
        exerciseId = json['exerciseId'] ?? json['exercise']?['id'],
        setExecutions = json['setExecutions'];

  Map toJson() => {
        'id': id,
        'sequence': sequence,
        'distance': distance,
        'weight': weight,
        'setExecutions': setExecutions,
        'exerciseId': exerciseId,
        'reps': reps,
      };

  @override
  List<Object?> get props => [
        reps,
        sequence,
        id,
        distance,
        weight,
        exerciseId,
      ];
}
