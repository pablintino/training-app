part of 'database.dart';

@DataClassName('ExerciseM')
class Exercises extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();
}

@DataClassName('WorkoutM')
class Workouts extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();
}

@DataClassName('WorkoutSessionM')
class WorkoutSessions extends Table {
  IntColumn get id => integer()();

  IntColumn get weekDay => integer()();

  IntColumn get week => integer()();

  IntColumn get workoutId => integer()
      .nullable()
      .customConstraint('NULLABLE REFERENCES workouts(id)')();
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

  IntColumn get workoutSessionId => integer()
      .nullable()
      .customConstraint('NULLABLE REFERENCES workout_sessions(id)')();
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
      .nullable()
      .customConstraint('NULLABLE REFERENCES workout_items(id)')();

  IntColumn get exerciseId => integer()
      .nullable()
      .customConstraint('NULLABLE REFERENCES exercises(id)')();
}
