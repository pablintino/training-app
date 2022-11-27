import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/networking/clients.dart';
import 'package:training_app/networking/entities/exercise_dto.dart';
import 'package:training_app/networking/network_sync_isolate.dart';

class ExercisesRepository {
  static const int PAGE_SIZE = 10;

  late AppDatabase _db;
  late NetworkSyncIsolate networkSyncIsolate;
  late ExerciseClient exerciseClient;

  ExercisesRepository(
      {AppDatabase? db,
      ExerciseClient? exerciseClient,
      NetworkSyncIsolate? networkSyncIsolate}) {
    this._db = db ?? GetIt.instance<AppDatabase>();
    this.networkSyncIsolate =
        networkSyncIsolate ?? GetIt.instance<NetworkSyncIsolate>();
    this.exerciseClient = exerciseClient ?? GetIt.instance<ExerciseClient>();
  }

  Future<void> sync() {
    return networkSyncIsolate.launchExercisesSync();
  }

  Future<List<Exercise>> getExercisesByPage(
      int page, String? nameFilter) async {
    return await (nameFilter != null
            ? _db.exerciseDAO
                .getPagedExercisesContainsName(PAGE_SIZE, page, nameFilter)
            : _db.exerciseDAO.getPagedExercises(PAGE_SIZE, page))
        .then((exercises) =>
            exercises.map((e) => Exercise.fromModel(e)).toList());
  }

  Future<List<Exercise>> getExercises() async {
    return await (_db.exerciseDAO.getAllExercises()).then(
        (exercises) => exercises.map((e) => Exercise.fromModel(e)).toList());
  }

  Future<Exercise?> getByName(String name) async {
    return await _db.exerciseDAO
        .getByName(name)
        .then((value) => value != null ? Exercise.fromModel(value) : null);
  }

  Future<Exercise> createExercise(Exercise exercise) async {
    try {
      return await exerciseClient
          .createExercise(ExerciseDto(
              name: exercise.name, description: exercise.description))
          .then((exerciseResponse) async {
        await _db.exerciseDAO.insertExercise(ExercisesCompanion(
            name: Value(exerciseResponse.name!),
            id: Value(exerciseResponse.id!),
            description: Value(exerciseResponse.description)));
        return exerciseResponse;
      }).then((exerciseResponse) => Exercise.fromDto(exerciseResponse));
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<Exercise> updateExercise(Exercise exercise) async {
    try {
      return await exerciseClient
          .updateExercise(
              exercise.id!,
              ExerciseDto(
                  name: exercise.name, description: exercise.description))
          .then((exerciseResponse) async {
        _db.exerciseDAO.updateById(
            exerciseResponse.id!,
            ExercisesCompanion(
                name: Value(exerciseResponse.name!),
                description: Value(exerciseResponse.description)));
        return exerciseResponse;
      }).then((exerciseResponse) => Exercise.fromDto(exerciseResponse));
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<void> deleteExercise(int id) async {
    try {
      await exerciseClient.deleteExercise(id).then((_) async {
        await _db.exerciseDAO.deleteById(id);
      });
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}
