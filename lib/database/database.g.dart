// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class ExerciseM extends DataClass implements Insertable<ExerciseM> {
  final int id;
  final String name;
  final String? description;
  ExerciseM({required this.id, required this.name, this.description});
  factory ExerciseM.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return ExerciseM(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      description: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}description']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String?>(description);
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory ExerciseM.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseM(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
    };
  }

  ExerciseM copyWith({int? id, String? name, String? description}) => ExerciseM(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
      );
  @override
  String toString() {
    return (StringBuffer('ExerciseM(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseM &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description);
}

class ExercisesCompanion extends UpdateCompanion<ExerciseM> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required int id,
    required String name,
    this.description = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<ExerciseM> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String?>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    });
  }

  ExercisesCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String?>? description}) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String?>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, ExerciseM> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String?> description = GeneratedColumn<String?>(
      'description', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, description];
  @override
  String get aliasedName => _alias ?? 'exercises';
  @override
  String get actualTableName => 'exercises';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseM> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  ExerciseM map(Map<String, dynamic> data, {String? tablePrefix}) {
    return ExerciseM.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class WorkoutM extends DataClass implements Insertable<WorkoutM> {
  final int id;
  final String name;
  final String? description;
  WorkoutM({required this.id, required this.name, this.description});
  factory WorkoutM.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return WorkoutM(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      description: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}description']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String?>(description);
    }
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory WorkoutM.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutM(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
    };
  }

  WorkoutM copyWith({int? id, String? name, String? description}) => WorkoutM(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
      );
  @override
  String toString() {
    return (StringBuffer('WorkoutM(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutM &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description);
}

class WorkoutsCompanion extends UpdateCompanion<WorkoutM> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    required int id,
    required String name,
    this.description = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<WorkoutM> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String?>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    });
  }

  WorkoutsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String?>? description}) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String?>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, WorkoutM> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String?> description = GeneratedColumn<String?>(
      'description', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, description];
  @override
  String get aliasedName => _alias ?? 'workouts';
  @override
  String get actualTableName => 'workouts';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutM> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  WorkoutM map(Map<String, dynamic> data, {String? tablePrefix}) {
    return WorkoutM.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class WorkoutSessionM extends DataClass implements Insertable<WorkoutSessionM> {
  final int id;
  final int weekDay;
  final int week;
  final int workoutId;
  WorkoutSessionM(
      {required this.id,
      required this.weekDay,
      required this.week,
      required this.workoutId});
  factory WorkoutSessionM.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return WorkoutSessionM(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      weekDay: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}week_day'])!,
      week: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}week'])!,
      workoutId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}workout_id'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['week_day'] = Variable<int>(weekDay);
    map['week'] = Variable<int>(week);
    map['workout_id'] = Variable<int>(workoutId);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      weekDay: Value(weekDay),
      week: Value(week),
      workoutId: Value(workoutId),
    );
  }

  factory WorkoutSessionM.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSessionM(
      id: serializer.fromJson<int>(json['id']),
      weekDay: serializer.fromJson<int>(json['weekDay']),
      week: serializer.fromJson<int>(json['week']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weekDay': serializer.toJson<int>(weekDay),
      'week': serializer.toJson<int>(week),
      'workoutId': serializer.toJson<int>(workoutId),
    };
  }

  WorkoutSessionM copyWith(
          {int? id, int? weekDay, int? week, int? workoutId}) =>
      WorkoutSessionM(
        id: id ?? this.id,
        weekDay: weekDay ?? this.weekDay,
        week: week ?? this.week,
        workoutId: workoutId ?? this.workoutId,
      );
  @override
  String toString() {
    return (StringBuffer('WorkoutSessionM(')
          ..write('id: $id, ')
          ..write('weekDay: $weekDay, ')
          ..write('week: $week, ')
          ..write('workoutId: $workoutId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weekDay, week, workoutId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSessionM &&
          other.id == this.id &&
          other.weekDay == this.weekDay &&
          other.week == this.week &&
          other.workoutId == this.workoutId);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSessionM> {
  final Value<int> id;
  final Value<int> weekDay;
  final Value<int> week;
  final Value<int> workoutId;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.weekDay = const Value.absent(),
    this.week = const Value.absent(),
    this.workoutId = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required int id,
    required int weekDay,
    required int week,
    required int workoutId,
  })  : id = Value(id),
        weekDay = Value(weekDay),
        week = Value(week),
        workoutId = Value(workoutId);
  static Insertable<WorkoutSessionM> custom({
    Expression<int>? id,
    Expression<int>? weekDay,
    Expression<int>? week,
    Expression<int>? workoutId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekDay != null) 'week_day': weekDay,
      if (week != null) 'week': week,
      if (workoutId != null) 'workout_id': workoutId,
    });
  }

  WorkoutSessionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? weekDay,
      Value<int>? week,
      Value<int>? workoutId}) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      weekDay: weekDay ?? this.weekDay,
      week: week ?? this.week,
      workoutId: workoutId ?? this.workoutId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weekDay.present) {
      map['week_day'] = Variable<int>(weekDay.value);
    }
    if (week.present) {
      map['week'] = Variable<int>(week.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('weekDay: $weekDay, ')
          ..write('week: $week, ')
          ..write('workoutId: $workoutId')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSessionM> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _weekDayMeta = const VerificationMeta('weekDay');
  @override
  late final GeneratedColumn<int?> weekDay = GeneratedColumn<int?>(
      'week_day', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _weekMeta = const VerificationMeta('week');
  @override
  late final GeneratedColumn<int?> week = GeneratedColumn<int?>(
      'week', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _workoutIdMeta = const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int?> workoutId = GeneratedColumn<int?>(
      'workout_id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES workouts(id) ON DELETE CASCADE');
  @override
  List<GeneratedColumn> get $columns => [id, weekDay, week, workoutId];
  @override
  String get aliasedName => _alias ?? 'workout_sessions';
  @override
  String get actualTableName => 'workout_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSessionM> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('week_day')) {
      context.handle(_weekDayMeta,
          weekDay.isAcceptableOrUnknown(data['week_day']!, _weekDayMeta));
    } else if (isInserting) {
      context.missing(_weekDayMeta);
    }
    if (data.containsKey('week')) {
      context.handle(
          _weekMeta, week.isAcceptableOrUnknown(data['week']!, _weekMeta));
    } else if (isInserting) {
      context.missing(_weekMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  WorkoutSessionM map(Map<String, dynamic> data, {String? tablePrefix}) {
    return WorkoutSessionM.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutItemM extends DataClass implements Insertable<WorkoutItemM> {
  final int id;
  final String name;
  final int sequence;
  final int? rounds;
  final int? restTimeSecs;
  final int? timeCapSecs;
  final int? workTimeSecs;
  final String? workModality;
  final int workoutSessionId;
  WorkoutItemM(
      {required this.id,
      required this.name,
      required this.sequence,
      this.rounds,
      this.restTimeSecs,
      this.timeCapSecs,
      this.workTimeSecs,
      this.workModality,
      required this.workoutSessionId});
  factory WorkoutItemM.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return WorkoutItemM(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      sequence: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sequence'])!,
      rounds: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}rounds']),
      restTimeSecs: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}rest_time_secs']),
      timeCapSecs: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}time_cap_secs']),
      workTimeSecs: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}work_time_secs']),
      workModality: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}work_modality']),
      workoutSessionId: const IntType().mapFromDatabaseResponse(
          data['${effectivePrefix}workout_session_id'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sequence'] = Variable<int>(sequence);
    if (!nullToAbsent || rounds != null) {
      map['rounds'] = Variable<int?>(rounds);
    }
    if (!nullToAbsent || restTimeSecs != null) {
      map['rest_time_secs'] = Variable<int?>(restTimeSecs);
    }
    if (!nullToAbsent || timeCapSecs != null) {
      map['time_cap_secs'] = Variable<int?>(timeCapSecs);
    }
    if (!nullToAbsent || workTimeSecs != null) {
      map['work_time_secs'] = Variable<int?>(workTimeSecs);
    }
    if (!nullToAbsent || workModality != null) {
      map['work_modality'] = Variable<String?>(workModality);
    }
    map['workout_session_id'] = Variable<int>(workoutSessionId);
    return map;
  }

  WorkoutItemsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutItemsCompanion(
      id: Value(id),
      name: Value(name),
      sequence: Value(sequence),
      rounds:
          rounds == null && nullToAbsent ? const Value.absent() : Value(rounds),
      restTimeSecs: restTimeSecs == null && nullToAbsent
          ? const Value.absent()
          : Value(restTimeSecs),
      timeCapSecs: timeCapSecs == null && nullToAbsent
          ? const Value.absent()
          : Value(timeCapSecs),
      workTimeSecs: workTimeSecs == null && nullToAbsent
          ? const Value.absent()
          : Value(workTimeSecs),
      workModality: workModality == null && nullToAbsent
          ? const Value.absent()
          : Value(workModality),
      workoutSessionId: Value(workoutSessionId),
    );
  }

  factory WorkoutItemM.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutItemM(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sequence: serializer.fromJson<int>(json['sequence']),
      rounds: serializer.fromJson<int?>(json['rounds']),
      restTimeSecs: serializer.fromJson<int?>(json['restTimeSecs']),
      timeCapSecs: serializer.fromJson<int?>(json['timeCapSecs']),
      workTimeSecs: serializer.fromJson<int?>(json['workTimeSecs']),
      workModality: serializer.fromJson<String?>(json['workModality']),
      workoutSessionId: serializer.fromJson<int>(json['workoutSessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sequence': serializer.toJson<int>(sequence),
      'rounds': serializer.toJson<int?>(rounds),
      'restTimeSecs': serializer.toJson<int?>(restTimeSecs),
      'timeCapSecs': serializer.toJson<int?>(timeCapSecs),
      'workTimeSecs': serializer.toJson<int?>(workTimeSecs),
      'workModality': serializer.toJson<String?>(workModality),
      'workoutSessionId': serializer.toJson<int>(workoutSessionId),
    };
  }

  WorkoutItemM copyWith(
          {int? id,
          String? name,
          int? sequence,
          int? rounds,
          int? restTimeSecs,
          int? timeCapSecs,
          int? workTimeSecs,
          String? workModality,
          int? workoutSessionId}) =>
      WorkoutItemM(
        id: id ?? this.id,
        name: name ?? this.name,
        sequence: sequence ?? this.sequence,
        rounds: rounds ?? this.rounds,
        restTimeSecs: restTimeSecs ?? this.restTimeSecs,
        timeCapSecs: timeCapSecs ?? this.timeCapSecs,
        workTimeSecs: workTimeSecs ?? this.workTimeSecs,
        workModality: workModality ?? this.workModality,
        workoutSessionId: workoutSessionId ?? this.workoutSessionId,
      );
  @override
  String toString() {
    return (StringBuffer('WorkoutItemM(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sequence: $sequence, ')
          ..write('rounds: $rounds, ')
          ..write('restTimeSecs: $restTimeSecs, ')
          ..write('timeCapSecs: $timeCapSecs, ')
          ..write('workTimeSecs: $workTimeSecs, ')
          ..write('workModality: $workModality, ')
          ..write('workoutSessionId: $workoutSessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sequence, rounds, restTimeSecs,
      timeCapSecs, workTimeSecs, workModality, workoutSessionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutItemM &&
          other.id == this.id &&
          other.name == this.name &&
          other.sequence == this.sequence &&
          other.rounds == this.rounds &&
          other.restTimeSecs == this.restTimeSecs &&
          other.timeCapSecs == this.timeCapSecs &&
          other.workTimeSecs == this.workTimeSecs &&
          other.workModality == this.workModality &&
          other.workoutSessionId == this.workoutSessionId);
}

class WorkoutItemsCompanion extends UpdateCompanion<WorkoutItemM> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sequence;
  final Value<int?> rounds;
  final Value<int?> restTimeSecs;
  final Value<int?> timeCapSecs;
  final Value<int?> workTimeSecs;
  final Value<String?> workModality;
  final Value<int> workoutSessionId;
  const WorkoutItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sequence = const Value.absent(),
    this.rounds = const Value.absent(),
    this.restTimeSecs = const Value.absent(),
    this.timeCapSecs = const Value.absent(),
    this.workTimeSecs = const Value.absent(),
    this.workModality = const Value.absent(),
    this.workoutSessionId = const Value.absent(),
  });
  WorkoutItemsCompanion.insert({
    required int id,
    required String name,
    required int sequence,
    this.rounds = const Value.absent(),
    this.restTimeSecs = const Value.absent(),
    this.timeCapSecs = const Value.absent(),
    this.workTimeSecs = const Value.absent(),
    this.workModality = const Value.absent(),
    required int workoutSessionId,
  })  : id = Value(id),
        name = Value(name),
        sequence = Value(sequence),
        workoutSessionId = Value(workoutSessionId);
  static Insertable<WorkoutItemM> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sequence,
    Expression<int?>? rounds,
    Expression<int?>? restTimeSecs,
    Expression<int?>? timeCapSecs,
    Expression<int?>? workTimeSecs,
    Expression<String?>? workModality,
    Expression<int>? workoutSessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sequence != null) 'sequence': sequence,
      if (rounds != null) 'rounds': rounds,
      if (restTimeSecs != null) 'rest_time_secs': restTimeSecs,
      if (timeCapSecs != null) 'time_cap_secs': timeCapSecs,
      if (workTimeSecs != null) 'work_time_secs': workTimeSecs,
      if (workModality != null) 'work_modality': workModality,
      if (workoutSessionId != null) 'workout_session_id': workoutSessionId,
    });
  }

  WorkoutItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? sequence,
      Value<int?>? rounds,
      Value<int?>? restTimeSecs,
      Value<int?>? timeCapSecs,
      Value<int?>? workTimeSecs,
      Value<String?>? workModality,
      Value<int>? workoutSessionId}) {
    return WorkoutItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
      rounds: rounds ?? this.rounds,
      restTimeSecs: restTimeSecs ?? this.restTimeSecs,
      timeCapSecs: timeCapSecs ?? this.timeCapSecs,
      workTimeSecs: workTimeSecs ?? this.workTimeSecs,
      workModality: workModality ?? this.workModality,
      workoutSessionId: workoutSessionId ?? this.workoutSessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int?>(rounds.value);
    }
    if (restTimeSecs.present) {
      map['rest_time_secs'] = Variable<int?>(restTimeSecs.value);
    }
    if (timeCapSecs.present) {
      map['time_cap_secs'] = Variable<int?>(timeCapSecs.value);
    }
    if (workTimeSecs.present) {
      map['work_time_secs'] = Variable<int?>(workTimeSecs.value);
    }
    if (workModality.present) {
      map['work_modality'] = Variable<String?>(workModality.value);
    }
    if (workoutSessionId.present) {
      map['workout_session_id'] = Variable<int>(workoutSessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sequence: $sequence, ')
          ..write('rounds: $rounds, ')
          ..write('restTimeSecs: $restTimeSecs, ')
          ..write('timeCapSecs: $timeCapSecs, ')
          ..write('workTimeSecs: $workTimeSecs, ')
          ..write('workModality: $workModality, ')
          ..write('workoutSessionId: $workoutSessionId')
          ..write(')'))
        .toString();
  }
}

class $WorkoutItemsTable extends WorkoutItems
    with TableInfo<$WorkoutItemsTable, WorkoutItemM> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutItemsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _sequenceMeta = const VerificationMeta('sequence');
  @override
  late final GeneratedColumn<int?> sequence = GeneratedColumn<int?>(
      'sequence', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int?> rounds = GeneratedColumn<int?>(
      'rounds', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _restTimeSecsMeta =
      const VerificationMeta('restTimeSecs');
  @override
  late final GeneratedColumn<int?> restTimeSecs = GeneratedColumn<int?>(
      'rest_time_secs', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _timeCapSecsMeta =
      const VerificationMeta('timeCapSecs');
  @override
  late final GeneratedColumn<int?> timeCapSecs = GeneratedColumn<int?>(
      'time_cap_secs', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _workTimeSecsMeta =
      const VerificationMeta('workTimeSecs');
  @override
  late final GeneratedColumn<int?> workTimeSecs = GeneratedColumn<int?>(
      'work_time_secs', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _workModalityMeta =
      const VerificationMeta('workModality');
  @override
  late final GeneratedColumn<String?> workModality = GeneratedColumn<String?>(
      'work_modality', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _workoutSessionIdMeta =
      const VerificationMeta('workoutSessionId');
  @override
  late final GeneratedColumn<int?> workoutSessionId = GeneratedColumn<int?>(
      'workout_session_id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES workout_sessions(id) ON DELETE CASCADE');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        sequence,
        rounds,
        restTimeSecs,
        timeCapSecs,
        workTimeSecs,
        workModality,
        workoutSessionId
      ];
  @override
  String get aliasedName => _alias ?? 'workout_items';
  @override
  String get actualTableName => 'workout_items';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutItemM> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(_sequenceMeta,
          sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta));
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('rounds')) {
      context.handle(_roundsMeta,
          rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta));
    }
    if (data.containsKey('rest_time_secs')) {
      context.handle(
          _restTimeSecsMeta,
          restTimeSecs.isAcceptableOrUnknown(
              data['rest_time_secs']!, _restTimeSecsMeta));
    }
    if (data.containsKey('time_cap_secs')) {
      context.handle(
          _timeCapSecsMeta,
          timeCapSecs.isAcceptableOrUnknown(
              data['time_cap_secs']!, _timeCapSecsMeta));
    }
    if (data.containsKey('work_time_secs')) {
      context.handle(
          _workTimeSecsMeta,
          workTimeSecs.isAcceptableOrUnknown(
              data['work_time_secs']!, _workTimeSecsMeta));
    }
    if (data.containsKey('work_modality')) {
      context.handle(
          _workModalityMeta,
          workModality.isAcceptableOrUnknown(
              data['work_modality']!, _workModalityMeta));
    }
    if (data.containsKey('workout_session_id')) {
      context.handle(
          _workoutSessionIdMeta,
          workoutSessionId.isAcceptableOrUnknown(
              data['workout_session_id']!, _workoutSessionIdMeta));
    } else if (isInserting) {
      context.missing(_workoutSessionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  WorkoutItemM map(Map<String, dynamic> data, {String? tablePrefix}) {
    return WorkoutItemM.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $WorkoutItemsTable createAlias(String alias) {
    return $WorkoutItemsTable(attachedDatabase, alias);
  }
}

class WorkoutSetM extends DataClass implements Insertable<WorkoutSetM> {
  final int id;
  final int sequence;
  final int? reps;
  final int? distance;
  final double? weight;
  final int? setExecutions;
  final int workoutItemId;
  final int? exerciseId;
  WorkoutSetM(
      {required this.id,
      required this.sequence,
      this.reps,
      this.distance,
      this.weight,
      this.setExecutions,
      required this.workoutItemId,
      this.exerciseId});
  factory WorkoutSetM.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return WorkoutSetM(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      sequence: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sequence'])!,
      reps: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}reps']),
      distance: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}distance']),
      weight: const RealType()
          .mapFromDatabaseResponse(data['${effectivePrefix}weight']),
      setExecutions: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}set_executions']),
      workoutItemId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}workout_item_id'])!,
      exerciseId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}exercise_id']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sequence'] = Variable<int>(sequence);
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int?>(reps);
    }
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<int?>(distance);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double?>(weight);
    }
    if (!nullToAbsent || setExecutions != null) {
      map['set_executions'] = Variable<int?>(setExecutions);
    }
    map['workout_item_id'] = Variable<int>(workoutItemId);
    if (!nullToAbsent || exerciseId != null) {
      map['exercise_id'] = Variable<int?>(exerciseId);
    }
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      sequence: Value(sequence),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      distance: distance == null && nullToAbsent
          ? const Value.absent()
          : Value(distance),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      setExecutions: setExecutions == null && nullToAbsent
          ? const Value.absent()
          : Value(setExecutions),
      workoutItemId: Value(workoutItemId),
      exerciseId: exerciseId == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseId),
    );
  }

  factory WorkoutSetM.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSetM(
      id: serializer.fromJson<int>(json['id']),
      sequence: serializer.fromJson<int>(json['sequence']),
      reps: serializer.fromJson<int?>(json['reps']),
      distance: serializer.fromJson<int?>(json['distance']),
      weight: serializer.fromJson<double?>(json['weight']),
      setExecutions: serializer.fromJson<int?>(json['setExecutions']),
      workoutItemId: serializer.fromJson<int>(json['workoutItemId']),
      exerciseId: serializer.fromJson<int?>(json['exerciseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sequence': serializer.toJson<int>(sequence),
      'reps': serializer.toJson<int?>(reps),
      'distance': serializer.toJson<int?>(distance),
      'weight': serializer.toJson<double?>(weight),
      'setExecutions': serializer.toJson<int?>(setExecutions),
      'workoutItemId': serializer.toJson<int>(workoutItemId),
      'exerciseId': serializer.toJson<int?>(exerciseId),
    };
  }

  WorkoutSetM copyWith(
          {int? id,
          int? sequence,
          int? reps,
          int? distance,
          double? weight,
          int? setExecutions,
          int? workoutItemId,
          int? exerciseId}) =>
      WorkoutSetM(
        id: id ?? this.id,
        sequence: sequence ?? this.sequence,
        reps: reps ?? this.reps,
        distance: distance ?? this.distance,
        weight: weight ?? this.weight,
        setExecutions: setExecutions ?? this.setExecutions,
        workoutItemId: workoutItemId ?? this.workoutItemId,
        exerciseId: exerciseId ?? this.exerciseId,
      );
  @override
  String toString() {
    return (StringBuffer('WorkoutSetM(')
          ..write('id: $id, ')
          ..write('sequence: $sequence, ')
          ..write('reps: $reps, ')
          ..write('distance: $distance, ')
          ..write('weight: $weight, ')
          ..write('setExecutions: $setExecutions, ')
          ..write('workoutItemId: $workoutItemId, ')
          ..write('exerciseId: $exerciseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sequence, reps, distance, weight,
      setExecutions, workoutItemId, exerciseId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSetM &&
          other.id == this.id &&
          other.sequence == this.sequence &&
          other.reps == this.reps &&
          other.distance == this.distance &&
          other.weight == this.weight &&
          other.setExecutions == this.setExecutions &&
          other.workoutItemId == this.workoutItemId &&
          other.exerciseId == this.exerciseId);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSetM> {
  final Value<int> id;
  final Value<int> sequence;
  final Value<int?> reps;
  final Value<int?> distance;
  final Value<double?> weight;
  final Value<int?> setExecutions;
  final Value<int> workoutItemId;
  final Value<int?> exerciseId;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.sequence = const Value.absent(),
    this.reps = const Value.absent(),
    this.distance = const Value.absent(),
    this.weight = const Value.absent(),
    this.setExecutions = const Value.absent(),
    this.workoutItemId = const Value.absent(),
    this.exerciseId = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    required int id,
    required int sequence,
    this.reps = const Value.absent(),
    this.distance = const Value.absent(),
    this.weight = const Value.absent(),
    this.setExecutions = const Value.absent(),
    required int workoutItemId,
    this.exerciseId = const Value.absent(),
  })  : id = Value(id),
        sequence = Value(sequence),
        workoutItemId = Value(workoutItemId);
  static Insertable<WorkoutSetM> custom({
    Expression<int>? id,
    Expression<int>? sequence,
    Expression<int?>? reps,
    Expression<int?>? distance,
    Expression<double?>? weight,
    Expression<int?>? setExecutions,
    Expression<int>? workoutItemId,
    Expression<int?>? exerciseId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sequence != null) 'sequence': sequence,
      if (reps != null) 'reps': reps,
      if (distance != null) 'distance': distance,
      if (weight != null) 'weight': weight,
      if (setExecutions != null) 'set_executions': setExecutions,
      if (workoutItemId != null) 'workout_item_id': workoutItemId,
      if (exerciseId != null) 'exercise_id': exerciseId,
    });
  }

  WorkoutSetsCompanion copyWith(
      {Value<int>? id,
      Value<int>? sequence,
      Value<int?>? reps,
      Value<int?>? distance,
      Value<double?>? weight,
      Value<int?>? setExecutions,
      Value<int>? workoutItemId,
      Value<int?>? exerciseId}) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      sequence: sequence ?? this.sequence,
      reps: reps ?? this.reps,
      distance: distance ?? this.distance,
      weight: weight ?? this.weight,
      setExecutions: setExecutions ?? this.setExecutions,
      workoutItemId: workoutItemId ?? this.workoutItemId,
      exerciseId: exerciseId ?? this.exerciseId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int?>(reps.value);
    }
    if (distance.present) {
      map['distance'] = Variable<int?>(distance.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double?>(weight.value);
    }
    if (setExecutions.present) {
      map['set_executions'] = Variable<int?>(setExecutions.value);
    }
    if (workoutItemId.present) {
      map['workout_item_id'] = Variable<int>(workoutItemId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int?>(exerciseId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('sequence: $sequence, ')
          ..write('reps: $reps, ')
          ..write('distance: $distance, ')
          ..write('weight: $weight, ')
          ..write('setExecutions: $setExecutions, ')
          ..write('workoutItemId: $workoutItemId, ')
          ..write('exerciseId: $exerciseId')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSetM> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _sequenceMeta = const VerificationMeta('sequence');
  @override
  late final GeneratedColumn<int?> sequence = GeneratedColumn<int?>(
      'sequence', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int?> reps = GeneratedColumn<int?>(
      'reps', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _distanceMeta = const VerificationMeta('distance');
  @override
  late final GeneratedColumn<int?> distance = GeneratedColumn<int?>(
      'distance', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double?> weight = GeneratedColumn<double?>(
      'weight', aliasedName, true,
      type: const RealType(), requiredDuringInsert: false);
  final VerificationMeta _setExecutionsMeta =
      const VerificationMeta('setExecutions');
  @override
  late final GeneratedColumn<int?> setExecutions = GeneratedColumn<int?>(
      'set_executions', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _workoutItemIdMeta =
      const VerificationMeta('workoutItemId');
  @override
  late final GeneratedColumn<int?> workoutItemId = GeneratedColumn<int?>(
      'workout_item_id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES workout_items(id) ON DELETE CASCADE');
  final VerificationMeta _exerciseIdMeta = const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<int?> exerciseId = GeneratedColumn<int?>(
      'exercise_id', aliasedName, true,
      type: const IntType(),
      requiredDuringInsert: false,
      $customConstraints: 'NULLABLE REFERENCES exercises(id)');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sequence,
        reps,
        distance,
        weight,
        setExecutions,
        workoutItemId,
        exerciseId
      ];
  @override
  String get aliasedName => _alias ?? 'workout_sets';
  @override
  String get actualTableName => 'workout_sets';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSetM> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(_sequenceMeta,
          sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta));
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('distance')) {
      context.handle(_distanceMeta,
          distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('set_executions')) {
      context.handle(
          _setExecutionsMeta,
          setExecutions.isAcceptableOrUnknown(
              data['set_executions']!, _setExecutionsMeta));
    }
    if (data.containsKey('workout_item_id')) {
      context.handle(
          _workoutItemIdMeta,
          workoutItemId.isAcceptableOrUnknown(
              data['workout_item_id']!, _workoutItemIdMeta));
    } else if (isInserting) {
      context.missing(_workoutItemIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  WorkoutSetM map(Map<String, dynamic> data, {String? tablePrefix}) {
    return WorkoutSetM.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  _$AppDatabase.connect(DatabaseConnection c) : super.connect(c);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $WorkoutSessionsTable workoutSessions =
      $WorkoutSessionsTable(this);
  late final $WorkoutItemsTable workoutItems = $WorkoutItemsTable(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final ExerciseDAO exerciseDAO = ExerciseDAO(this as AppDatabase);
  late final WorkoutDAO workoutDAO = WorkoutDAO(this as AppDatabase);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [exercises, workouts, workoutSessions, workoutItems, workoutSets];
}
