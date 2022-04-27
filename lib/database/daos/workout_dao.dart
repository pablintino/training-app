import 'package:training_app/database/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/extensions/native.dart';

part 'workout_dao.g.dart';

@DriftAccessor(tables: [Workouts, WorkoutSessions, WorkoutItems, WorkoutSets])
class WorkoutDAO extends DatabaseAccessor<AppDatabase> with _$WorkoutDAOMixin {
  WorkoutDAO(AppDatabase db) : super(db);
}
