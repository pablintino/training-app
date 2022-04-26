import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/app_config.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/networking/clients.dart';
import 'package:training_app/networking/entities/exercise_dto.dart';
import 'package:training_app/networking/network_sync_isolate.dart';

class ExercisesRepository {
  static const int PAGE_SIZE = 10;

  final _db = GetIt.instance<AppDatabase>();
  final _networkIsolate = GetIt.instance<NetworkSyncIsolate>();
  final _exerciseClient = ExerciseClient(GetIt.instance<Dio>());

  Future<List<Exercise>> getExercisesByPage(
      int page, String? nameFilter) async {
    _networkIsolate
        .launchExercisesSync()
        .then((value) => print('Finished'))
        .catchError((_) => print('error'));
    List<ExerciseM> exercises = nameFilter != null
        ? await _db.exerciseDAO
            .getPagedExercisesContainsName(PAGE_SIZE, page, nameFilter)
        : await _db.exerciseDAO.getPagedExercises(PAGE_SIZE, page);

    // TODO Temporal mapping
    return exercises.map((e) => Exercise.fromJson(e.toJson())).toList();
  }

  Future<Exercise?> getByName(String name) async {
    //TODO Temporal mapping
    return _db.exerciseDAO.getByName(name).then(
        (value) => value != null ? Exercise.fromJson(value.toJson()) : null);
  }

  Future<Exercise> createExercise(Exercise exercise) async {
    try {
      return await _exerciseClient
          .createExercise(ExerciseDto(
              name: exercise.name, description: exercise.description))
          .then((exerciseResponse) async {
        await _db.exerciseDAO.insertExercise(ExercisesCompanion(
            name: Value(exerciseResponse.name!),
            id: Value(exerciseResponse.id!),
            description: Value(exerciseResponse.description)));
        return exerciseResponse;
      }).then((exerciseResponse) =>
              // TODO Rewrite this mapping onto something reusable
              Exercise(
                  id: exerciseResponse.id,
                  name: exerciseResponse.name,
                  description: exerciseResponse.description));
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<Exercise> updateExercise(Exercise exercise) async {
    try {
      return await _exerciseClient
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
      }).then((exerciseResponse) =>
              // TODO Rewrite this mapping onto something reusable
              Exercise(
                  id: exerciseResponse.id,
                  name: exerciseResponse.name,
                  description: exerciseResponse.description));
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<void> deleteExercise(int id) async {
    try {
      await _exerciseClient.deleteExercise(id).then((_) async {
        await _db.exerciseDAO.deleteById(id);
      });
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}
