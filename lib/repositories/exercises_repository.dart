import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:training_app/app_config.dart';
import 'package:training_app/models/exercises_models.dart';

class ExercisesRepository {
  static const int _perPage = 10;
  final appConfig = AppConfigLoader().instance;

  Future<List<Exercise>> getExercises(int page) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${appConfig.apiUrl}/api/v1/exercises?page=$page&size=$_perPage'),
      );

      if (response.statusCode == 200) {
        Iterable exercisesList = json.decode(response.body)['data'];
        return List<Exercise>.from(
            exercisesList.map((model) => Exercise.fromJson(model)));
      }
    } catch (e) {
      print('EEEEEEEEEEEEEEEEEEEEE $e');
    }
    return [];
  }

  Future<Exercise> createExercise(Exercise exercise) async {
    try {
      final response = await http.post(
        Uri.parse('${appConfig.apiUrl}/api/v1/exercises'),
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
}
