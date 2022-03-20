import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:training_app/app_config.dart';
import 'package:training_app/models/exercises_models.dart';

class ExercisesRepository {
  static const int PAGE_SIZE = 10;
  final _appConfig = AppConfigLoader().instance;

  Future<List<Exercise>> getExercisesByPage(
      int page, String? nameFilter) async {
    final String searchFilter =
        nameFilter != null ? '&filters=cti_name=$nameFilter' : '';
    return _commonExercisesRetreival(Uri.parse(
        '${_appConfig.apiUrl}/api/v1/exercises?page=$page&size=$PAGE_SIZE&sort=name$searchFilter'));
  }

  Future<bool> existsByName(String name) async {
    return (await _commonExercisesRetreival(Uri.parse(
            '${_appConfig.apiUrl}/api/v1/exercises?filters=eq_name=$name')))
        .isNotEmpty;
  }

  Future<List<Exercise>> _commonExercisesRetreival(Uri uri) async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        Iterable exercisesList = json.decode(response.body)['data'];
        return List<Exercise>.from(
            exercisesList.map((model) => Exercise.fromJson(model)));
      }
      throw 'Unexpected response retrieving exercises';
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<Exercise> createExercise(Exercise exercise) async {
    try {
      final response = await http.post(
        Uri.parse('${_appConfig.apiUrl}/api/v1/exercises'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(exercise),
      );

      if (response.statusCode == 200) {
        return Exercise.fromJson(json.decode(response.body));
      }
      throw 'Unexpected response creating new exercise';
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<void> deleteExercise(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${_appConfig.apiUrl}/api/v1/exercises/$id'),
      );

      if (response.statusCode != 200) {
        throw 'Unexpected response deleting exercise';
      }
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}
