import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/networking/entities/exercise_dto.dart';
import 'package:training_app/networking/entities/page_dto.dart';
import 'package:training_app/networking/entities/workout_dtos.dart';

class ExerciseClient {
  static const int PAGE_SIZE = 50;

  late Dio dio;

  ExerciseClient({Dio? dio}) {
    this.dio = dio ?? GetIt.instance<Dio>();
  }

  Future<ExerciseDto> createExercise(ExerciseDto exerciseDto) async {
    try {
      Response exerciseData = await dio.post('/api/v1/exercises',
          data: exerciseDto.toJson(),
          options: Options(headers: {
            'Accept': 'application/json',
          }));
      return ExerciseDto.fromJson(exerciseData.data);
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  Future<ExerciseDto> updateExercise(int id, ExerciseDto exerciseDto) async {
    try {
      Response exerciseData = await dio.put('/api/v1/exercises/$id',
          data: exerciseDto.toJson(),
          options: Options(headers: {
            'Accept': 'application/json',
          }));
      return ExerciseDto.fromJson(exerciseData.data);
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  Future<ExerciseDto> getExercise({required String id}) async {
    try {
      Response exerciseData = await dio.get('/api/v1/exercises/$id');
      return ExerciseDto.fromJson(exerciseData.data);
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  Future<void> deleteExercise(int id) async {
    try {
      await dio.delete('/api/v1/exercises/$id');
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  Future<List<ExerciseDto>> getExercises({bool bulk = false}) async {
    try {
      if (bulk) {
        Response exerciseData = await dio.get('/api/v1/exercises');

        return List<ExerciseDto>.from(PageDto.fromJson(exerciseData.data)
            .data
            .map((model) => ExerciseDto.fromJson(model)));
      } else {
        final exercises = List<ExerciseDto>.empty(growable: true);
        for (int pageIndex = 0;; pageIndex++) {
          final page = await dio
              .get('/api/v1/exercises?page=$pageIndex&size=$PAGE_SIZE')
              .then((response) => PageDto.fromJson(response.data));

          exercises.addAll(List<ExerciseDto>.from(
              page.data.map((model) => ExerciseDto.fromJson(model))));
          if (!page.hasNext) {
            break;
          }
        }
        return exercises;
      }
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  void _handleError(DioError error) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (error.response != null) {
      print('Dio error!');
      print('STATUS: ${error.response?.statusCode}');
      print('DATA: ${error.response?.data}');
      print('HEADERS: ${error.response?.headers}');
    } else {
      // Error due to setting up or sending the request
      print('Error sending request!');
      print(error.message);
    }
    print(error.toString());
  }
}

class WorkoutClient {
  static const int PAGE_SIZE = 50;

  late Dio dio;

  WorkoutClient({Dio? dio}) {
    this.dio = dio ?? GetIt.instance<Dio>();
  }

  Future<WorkoutDto> getWorkout(int id, {bool fat = false}) async {
    try {
      Response exerciseData = await dio.get('/api/v1/workouts/$id?fat=$fat');
      return WorkoutDto.fromJson(exerciseData.data);
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  Future<void> deleteWorkout(int id) async {
    try {
      await dio.delete('/api/v1/workouts/$id');
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  Future<WorkoutDto> updateWorkout(int id, WorkoutDto workoutDto) async {
    try {
      Response workoutData = await dio.put('/api/v1/workouts/$id',
          data: workoutDto.toJson(),
          options: Options(headers: {
            'Accept': 'application/json',
          }));
      return WorkoutDto.fromJson(workoutData.data);
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  Future<WorkoutSessionDto> updateWorkoutSession(
      int id, WorkoutSessionDto workoutSessionDto) async {
    try {
      Response workoutSessionData =
          await dio.put('/api/v1/workouts/sessions/$id',
              data: workoutSessionDto.toJson(),
              options: Options(headers: {
                'Accept': 'application/json',
              }));
      return WorkoutSessionDto.fromJson(workoutSessionData.data);
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  Future<List<WorkoutDto>> getWorkouts(
      {bool bulk = false, bool fat = false}) async {
    try {
      if (bulk) {
        Response workoutData = await dio.get('/api/v1/workouts?fat=$fat');

        return List<WorkoutDto>.from(PageDto.fromJson(workoutData.data)
            .data
            .map((model) => WorkoutDto.fromJson(model)));
      } else {
        final workouts = List<WorkoutDto>.empty(growable: true);
        for (int pageIndex = 0;; pageIndex++) {
          final page = await dio
              .get('/api/v1/workouts?page=$pageIndex&size=$PAGE_SIZE&fat=$fat')
              .then((response) => PageDto.fromJson(response.data));

          workouts.addAll(List<WorkoutDto>.from(
              page.data.map((model) => WorkoutDto.fromJson(model))));
          if (!page.hasNext) {
            break;
          }
        }
        return workouts;
      }
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  void _handleError(DioError error) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (error.response != null) {
      print('Dio error!');
      print('STATUS: ${error.response?.statusCode}');
      print('DATA: ${error.response?.data}');
      print('HEADERS: ${error.response?.headers}');
    } else {
      // Error due to setting up or sending the request
      print('Error sending request!');
      print(error.message);
    }
    print(error.toString());
  }
}
