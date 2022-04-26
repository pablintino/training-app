part of 'database.dart';

@DataClassName('ExerciseM')
class Exercises extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();
}
