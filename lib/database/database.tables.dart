part of 'database.dart';

@DataClassName('ExerciseM')
class Exercises extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkoutM')
class Workouts extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkoutSessionM')
class WorkoutSessions extends Table {
  IntColumn get id => integer()();

  IntColumn get weekDay => integer()();

  IntColumn get week => integer()();

  IntColumn get workoutId =>
      integer().customConstraint('REFERENCES workouts(id) ON DELETE CASCADE')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkoutPhaseM')
class WorkoutPhases extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  IntColumn get sequence => integer()();

  IntColumn get workoutSessionId => integer()
      .customConstraint('REFERENCES workout_sessions(id) ON DELETE CASCADE')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkoutItemM')
class WorkoutItems extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  IntColumn get sequence => integer()();

  IntColumn get rounds => integer().nullable()();

  IntColumn get restTimeSecs => integer().nullable()();

  IntColumn get timeCapSecs => integer().nullable()();

  IntColumn get workTimeSecs => integer().nullable()();

  TextColumn get workModality => text().nullable()();

  IntColumn get workoutPhaseId => integer()
      .customConstraint('REFERENCES workout_phases(id) ON DELETE CASCADE')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkoutSetM')
class WorkoutSets extends Table {
  IntColumn get id => integer()();

  IntColumn get sequence => integer()();

  IntColumn get reps => integer().nullable()();

  IntColumn get distance => integer().nullable()();

  RealColumn get weight => real().nullable()();

  IntColumn get setExecutions => integer().nullable()();

  IntColumn get workoutItemId => integer()
      .customConstraint('REFERENCES workout_items(id) ON DELETE CASCADE')();

  IntColumn get exerciseId =>
      integer().customConstraint('REFERENCES exercises(id)')();

  @override
  Set<Column> get primaryKey => {id};
}
