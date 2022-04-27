import 'package:training_app/database/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/extensions/native.dart';

part 'exercise_dao.g.dart';

@DriftAccessor(tables: [Exercises])
class ExerciseDAO extends DatabaseAccessor<AppDatabase>
    with _$ExerciseDAOMixin {
  ExerciseDAO(AppDatabase db) : super(db);

  Future insertExercise(ExercisesCompanion exercise) =>
      into(exercises).insert(exercise);

  Future<List<ExerciseM>> getAllExercises() => (select(exercises)
        ..orderBy([(t) => OrderingTerm(expression: t.name.lower())]))
      .get();

  Future<List<ExerciseM>> getPagedExercises(int limit, int offset) =>
      (select(exercises)
            ..limit(limit, offset: offset)
            ..orderBy([(t) => OrderingTerm(expression: t.name.lower())]))
          .get();

  Future<List<ExerciseM>> getPagedExercisesContainsName(
          int limit, int offset, String name) =>
      (select(exercises)
            ..where((tbl) => tbl.name.containsCase(name, caseSensitive: false))
            ..limit(limit, offset: offset))
          .get();

  Future<ExerciseM?> getById(int id) =>
      (select(exercises)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<ExerciseM?> getByName(String name) =>
      (select(exercises)..where((tbl) => tbl.name.equals(name)))
          .getSingleOrNull();

  Future updateById(int id, ExercisesCompanion companion) {
    return (update(exercises)..where((t) => t.id.equals(id))).write(
      ExercisesCompanion(
        name: companion.name,
        description: companion.description,
      ),
    );
  }

  Future<int> deleteById(int id) =>
      (delete(exercises)..where((t) => t.id.equals(id))).go();
}
