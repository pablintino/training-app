import 'package:training_app/database/database.dart';
import 'package:drift/drift.dart';

part 'exercise_dao.g.dart';

@DriftAccessor(tables: [Exercises])
class ExerciseDAO extends DatabaseAccessor<AppDatabase>
    with _$ExerciseDAOMixin {
  ExerciseDAO(AppDatabase db) : super(db);

  Future insertExercise(ExercisesCompanion exercise) =>
      into(exercises).insert(exercise);

  Future<List<ExerciseM>> getAllExercises() => select(exercises).get();

  Future<List<ExerciseM>> getPagedExercises(int limit, int offset) =>
      (select(exercises)..limit(limit, offset: offset)).get();

  Future<ExerciseM> getExerciseById(int id) =>
      (select(exercises)..where((t) => t.id.equals(id))).getSingle();

  Future<ExerciseM> getExerciseByServerId(int id) =>
      (select(exercises)..where((t) => t.serverId.equals(id))).getSingle();
}
