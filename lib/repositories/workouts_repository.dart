import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:training_app/app_config.dart';
import 'package:training_app/models/workout_models.dart';

class WorkoutRepository {
  static const int PAGE_SIZE = 10;
  static const String _WORKOUT_BASE_PATH = '/api/v1/workouts';
  final _appConfig = AppConfigLoader().instance;

  Future<List<Workout>> getWorkoutsByPage(int page, String? nameFilter) async {
    final String searchFilter =
        nameFilter != null ? '&filters=cti_name=$nameFilter' : '';
    return _commonWorkoutRetrieval(Uri.parse(
        '${_appConfig.apiUrl}$_WORKOUT_BASE_PATH?page=$page&size=$PAGE_SIZE&sort=name$searchFilter'));
  }

  Future<Workout?> getByName(String name) async {
    final workouts = await _commonWorkoutRetrieval(Uri.parse(
        '${_appConfig.apiUrl}$_WORKOUT_BASE_PATH?filters=eq_name=$name'));
    return workouts.isNotEmpty ? workouts[0] : null;
  }

  Future<List<Workout>> _commonWorkoutRetrieval(Uri uri) async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        Iterable workoutList = json.decode(response.body)['data'];
        return List<Workout>.from(
            workoutList.map((model) => Workout.fromJson(model)));
      }
      throw 'Unexpected response retrieving workouts';
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<WorkoutSession> getWorkoutSession(int id, {bool fat = false}) async {
    try {
      final response = await http.get(Uri.parse(
          '${_appConfig.apiUrl}$_WORKOUT_BASE_PATH/sessions/$id?fat=$fat'));
      if (response.statusCode == 200) {
        return WorkoutSession.fromJson(json.decode(response.body));
      }
      throw 'Unexpected response retrieving workout session $id';
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<Workout> getWorkout(int id, {bool fat = false}) async {
    try {
      final response = await http.get(Uri.parse(
          '${_appConfig.apiUrl}$_WORKOUT_BASE_PATH/$id?fat=$fat'));
      if (response.statusCode == 200) {
        return Workout.fromJson(json.decode(response.body));
      }
      throw 'Unexpected response retrieving workout $id';
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<Workout> createWorkout(Workout workout) async {
    try {
      final response = await http.post(
        Uri.parse('${_appConfig.apiUrl}$_WORKOUT_BASE_PATH'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(workout),
      );

      if (response.statusCode == 200) {
        return Workout.fromJson(json.decode(response.body));
      }
      throw 'Unexpected response creating new workout';
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<Workout> updateWorkout(Workout workout) async {
    try {
      final response = await http.put(
        Uri.parse('${_appConfig.apiUrl}$_WORKOUT_BASE_PATH/${workout.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(workout),
      );

      if (response.statusCode == 200) {
        return Workout.fromJson(json.decode(response.body));
      }
      throw 'Unexpected response creating updating workout ${workout.id}';
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<void> deleteWorkout(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${_appConfig.apiUrl}/$_WORKOUT_BASE_PATH/$id'),
      );

      if (response.statusCode != 200) {
        throw 'Unexpected response deleting workout';
      }
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}
