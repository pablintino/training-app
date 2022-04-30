import 'package:get_it/get_it.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/networking/clients.dart';
import 'package:training_app/networking/network_sync_isolate.dart';

class WorkoutRepository {
  static const int PAGE_SIZE = 10;

  late NetworkSyncIsolate _networkIsolate;
  late WorkoutClient _workoutClient;
  late AppDatabase _db;

  WorkoutRepository(
      {AppDatabase? db,
      WorkoutClient? workoutClient,
      NetworkSyncIsolate? networkSyncIsolate}) {
    this._db = db ?? GetIt.instance<AppDatabase>();
    this._networkIsolate =
        networkSyncIsolate ?? GetIt.instance<NetworkSyncIsolate>();
    this._workoutClient = workoutClient ?? GetIt.instance<WorkoutClient>();
  }

  Future<List<Workout>> getWorkoutsByPage(int page,
      {String? nameFilter}) async {
    return await (nameFilter != null
            ? _db.workoutDAO
                .getPagedWorkoutsContainsName(PAGE_SIZE, page, nameFilter)
            : _db.workoutDAO.getPagedWorkouts(PAGE_SIZE, page))
        .then((workouts) =>
            workouts.map((model) => Workout.fromModel(model)).toList());
  }

  Future<Workout?> getByName(String name) async {}

  Future<WorkoutSession?> getWorkoutSession(int id, {bool fat = false}) async {
    return await (fat
        ? _db.workoutDAO.getJoinedSessionById(id).then((joinedWorkoutSession) =>
            joinedWorkoutSession != null
                ? WorkoutSession.fromJoinedModel(joinedWorkoutSession)
                : null)
        : _db.workoutDAO.getWorkoutSessionById(id).then((session) =>
            session != null ? WorkoutSession.fromModel(session) : null));
  }

  Future<Workout?> getWorkout(int id, {bool fat = false}) async {
    return await (fat
        ? _db.workoutDAO.getJoinedWorkoutById(id).then((joinedWorkout) =>
            joinedWorkout != null
                ? Workout.fromJoinedModel(joinedWorkout)
                : null)
        : _db.workoutDAO.getWorkoutById(id).then(
            (workout) => workout != null ? Workout.fromModel(workout) : null));
  }

  Future<Workout> createWorkout(Workout workout) async {
    return workout;
  }

  Future<Workout> updateWorkout(Workout workout) async {
    return workout;
  }

  Future<void> deleteWorkout(int id) async {}
}
