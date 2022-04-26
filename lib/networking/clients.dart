import 'package:dio/dio.dart';
import 'package:training_app/app_config.dart';
import 'package:training_app/networking/entities/exercise_dto.dart';
import 'package:training_app/networking/entities/page_dto.dart';

Dio createDioClient(AppConfig appConfig) {
  var dio = Dio();
  dio.options.baseUrl = appConfig.apiUrl;
  return dio;
}

class ExerciseClient {
  static const int PAGE_SIZE = 50;

  final Dio _dio;

  ExerciseClient(this._dio);

  Future<ExerciseDto> createExercise(ExerciseDto exerciseDto) async {
    try {
      Response exerciseData = await _dio.post('/api/v1/exercises',
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
      Response exerciseData = await _dio.put('/api/v1/exercises/$id',
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
      Response exerciseData = await _dio.get('/api/v1/exercises/$id');
      return ExerciseDto.fromJson(exerciseData.data);
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  Future<void> deleteExercise(int id) async {
    try {
      await _dio.delete('/api/v1/exercises/$id');
    } on DioError catch (e) {
      _handleError(e);
      throw e;
    }
  }

  Future<List<ExerciseDto>> getExercises({bool bulk = false}) async {
    try {
      if (bulk) {
        Response exerciseData = await _dio.get('/api/v1/exercises');

        return List<ExerciseDto>.from(PageDto.fromJson(exerciseData.data)
            .data
            .map((model) => ExerciseDto.fromJson(model)));
      } else {
        final exercises = List<ExerciseDto>.empty(growable: true);
        for (int pageIndex = 0;; pageIndex++) {
          final page = await _dio
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
