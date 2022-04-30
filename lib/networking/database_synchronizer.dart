import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/database/join_entities.dart';
import 'package:training_app/networking/clients.dart';
import 'package:training_app/networking/entities/exercise_dto.dart';
import 'package:training_app/networking/entities/workout_dtos.dart';
import 'package:tuple/tuple.dart';

enum DatabaseSyncRequestType { EXERCISES, WORKOUTS, ALL }

class DatabaseSyncRequest {
  final DatabaseSyncRequestType requestType;
  final SendPort sendPort;

  DatabaseSyncRequest(this.requestType, this.sendPort);
}

class DatabaseSynchronizer {
  late AppDatabase db;
  late ExerciseClient exerciseClient;
  late WorkoutClient workoutClient;

  DatabaseSynchronizer(
      {AppDatabase? db,
      ExerciseClient? exerciseClient,
      WorkoutClient? workoutClient}) {
    this.db = db ?? GetIt.instance<AppDatabase>();
    this.exerciseClient = exerciseClient ?? GetIt.instance<ExerciseClient>();
    this.workoutClient = workoutClient ?? GetIt.instance<WorkoutClient>();
  }

  Future<void> handleSyncRequest(DatabaseSyncRequest request) async {
    if (request.requestType == DatabaseSyncRequestType.EXERCISES) {
      await _handleExercisesSync();
    } else if (request.requestType == DatabaseSyncRequestType.WORKOUTS) {
      await _handleWorkoutsSync();
    } else if (request.requestType == DatabaseSyncRequestType.ALL) {
      // Order is important. First exercises and after them their dependencies
      await _handleExercisesSync();
      await _handleWorkoutsSync();
    }
  }

  Future<void> _handleExercisesSync() async {
    final dbExercises = await db.exerciseDAO.getAllExercises();

    final exercises = await exerciseClient.getExercises(bulk: false);
    for (final dbExercise in dbExercises) {
      ExerciseDto? remoteExercise =
          exercises.firstWhereOrNull((element) => element.id == dbExercise.id);
      if (remoteExercise == null) {
        await db.exerciseDAO.deleteById(dbExercise.id);
      } else {
        await db.exerciseDAO.updateById(
            dbExercise.id,
            ExercisesCompanion(
                name: Value(remoteExercise.name!),
                description: Value(remoteExercise.description)));
      }
    }

    for (final remoteExercise in exercises) {
      if (await db.exerciseDAO.getById(remoteExercise.id!) == null) {
        await db.exerciseDAO.insertExercise(ExercisesCompanion(
            id: Value(remoteExercise.id!),
            name: Value(remoteExercise.name!),
            description: Value(remoteExercise.description)));
      }
    }
  }

  Future<void> _handleWorkoutsSync() async {
    final serverWorkouts =
        await workoutClient.getWorkouts(bulk: false, fat: true);
    final dbWorkouts = await db.workoutDAO.getAllJoinedWorkouts();

    // Update workouts (and sub-entities) already present in DB
    for (final dbWorkout in dbWorkouts) {
      WorkoutDto? remoteWorkout = serverWorkouts
          .firstWhereOrNull((element) => element.id == dbWorkout.workout.id);
      if (remoteWorkout == null) {
        await db.workoutDAO.deleteWorkoutById(dbWorkout.workout.id);
      } else {
        await _handleDbWorkoutSync(dbWorkout, remoteWorkout);
      }
    }

    // Create new entities that are not in DB but in API
    await _createNewServerWorkouts(serverWorkouts);
    await _createNewServerWorkoutSessions(serverWorkouts);
    await _createNewServerWorkoutPhases(serverWorkouts);
    await _createNewServerWorkoutItems(serverWorkouts);
    await _createNewServerWorkoutSets(serverWorkouts);
  }

  Future<void> _createNewServerWorkouts(
      final List<WorkoutDto> serverWorkouts) async {
    for (final remoteWorkout in serverWorkouts) {
      if (await db.workoutDAO.getWorkoutById(remoteWorkout.id!) == null) {
        await db.workoutDAO.insertWorkout(WorkoutsCompanion(
            id: Value(remoteWorkout.id!),
            name: Value(remoteWorkout.name!),
            description: Value(remoteWorkout.description)));
      }
    }
  }

  Future<void> _createNewServerWorkoutSessions(
      final List<WorkoutDto> serverWorkouts) async {
    for (final remoteSession in serverWorkouts.expand((element) => element
        .sessions
        .map((e) => Tuple2<int, WorkoutSessionDto>(element.id!, e)))) {
      if (await db.workoutDAO.getWorkoutSessionById(remoteSession.item2.id!) ==
          null) {
        await db.workoutDAO.insertWorkoutSession(WorkoutSessionsCompanion(
            id: Value(remoteSession.item2.id!),
            workoutId: Value(remoteSession.item1),
            weekDay: Value(remoteSession.item2.weekDay!),
            week: Value(remoteSession.item2.week!)));
      }
    }
  }

  Future<void> _createNewServerWorkoutPhases(
      final List<WorkoutDto> serverWorkouts) async {
    for (final remotePhase in serverWorkouts
        .expand((element) => element.sessions)
        .expand((element) => element.phases
            .map((e) => Tuple2<int, WorkoutPhaseDto>(element.id!, e)))) {
      if (await db.workoutDAO.getWorkoutPhaseById(remotePhase.item2.id!) ==
          null) {
        await db.workoutDAO.insertWorkoutPhase(WorkoutPhasesCompanion(
            id: Value(remotePhase.item2.id!),
            sequence: Value(remotePhase.item2.sequence!),
            name: Value(remotePhase.item2.name!),
            workoutSessionId: Value(remotePhase.item1)));
      }
    }
  }

  Future<void> _createNewServerWorkoutItems(
      final List<WorkoutDto> serverWorkouts) async {
    for (final remoteItem in serverWorkouts
        .expand((element) => element.sessions)
        .expand((element) => element.phases)
        .expand((element) => element.items
            .map((e) => Tuple2<int, WorkoutItemDto>(element.id!, e)))) {
      if (await db.workoutDAO.getWorkoutItemById(remoteItem.item2.id!) ==
          null) {
        await db.workoutDAO.insertWorkoutItem(WorkoutItemsCompanion(
            id: Value(remoteItem.item2.id!),
            sequence: Value(remoteItem.item2.sequence!),
            workTimeSecs: Value(remoteItem.item2.workTimeSecs),
            workModality: Value(remoteItem.item2.workModality),
            restTimeSecs: Value(remoteItem.item2.restTimeSecs),
            rounds: Value(remoteItem.item2.rounds),
            name: Value(remoteItem.item2.name!),
            workoutPhaseId: Value(remoteItem.item1)));
      }
    }
  }

  Future<void> _createNewServerWorkoutSets(
      final List<WorkoutDto> serverWorkouts) async {
    for (final remoteSet in serverWorkouts
        .expand((element) => element.sessions)
        .expand((element) => element.phases)
        .expand((element) => element.items)
        .expand((element) => element.sets
            .map((e) => Tuple2<int, WorkoutSetDto>(element.id!, e)))) {
      if (await db.workoutDAO.getWorkoutSetById(remoteSet.item2.id!) == null) {
        await db.workoutDAO.insertWorkoutSet(WorkoutSetsCompanion(
            id: Value(remoteSet.item2.id!),
            sequence: Value(remoteSet.item2.sequence!),
            distance: Value(remoteSet.item2.distance),
            reps: Value(remoteSet.item2.reps),
            setExecutions: Value(remoteSet.item2.setExecutions),
            weight: Value(remoteSet.item2.weight),
            exerciseId: Value(remoteSet.item2.exerciseId!),
            workoutItemId: Value(remoteSet.item1)));
      }
    }
  }

  Future<void> _handleDbWorkoutSync(
      JoinedWorkoutM dbWorkout, WorkoutDto serverWorkout) async {
    db.workoutDAO.updateWorkoutById(
        dbWorkout.workout.id,
        WorkoutsCompanion(
            name: Value(serverWorkout.name!),
            description: Value(serverWorkout.description)));

    for (final dbSession in dbWorkout.sessions) {
      WorkoutSessionDto? remoteSession = serverWorkout.sessions
          .firstWhereOrNull((element) => element.id == dbSession.session.id);
      if (remoteSession == null) {
        await db.workoutDAO.deleteWorkoutSessionById(dbSession.session.id);
      } else {
        await _handleDbWorkoutSessionSync(dbSession, remoteSession);
      }
    }
  }

  Future<void> _handleDbWorkoutSessionSync(
      JoinedWorkoutSessionM dbWorkoutSession,
      WorkoutSessionDto serverWorkoutSession) async {
    db.workoutDAO.updateWorkoutSessionById(
        dbWorkoutSession.session.id,
        WorkoutSessionsCompanion(
            weekDay: Value(serverWorkoutSession.weekDay!),
            week: Value(serverWorkoutSession.week!)));

    for (final dbPhase in dbWorkoutSession.phases) {
      WorkoutPhaseDto? remotePhase = serverWorkoutSession.phases
          .firstWhereOrNull((element) => element.id == dbPhase.phase.id);
      if (remotePhase == null) {
        await db.workoutDAO.deleteWorkoutPhaseById(dbPhase.phase.id);
      } else {
        await _handleDbWorkoutPhaseSync(dbPhase, remotePhase);
      }
    }
  }

  Future<void> _handleDbWorkoutPhaseSync(JoinedWorkoutPhaseM dbWorkoutPhase,
      WorkoutPhaseDto serverWorkoutPhase) async {
    db.workoutDAO.updateWorkoutPhaseById(
        dbWorkoutPhase.phase.id,
        WorkoutPhasesCompanion(
            name: Value(serverWorkoutPhase.name!),
            sequence: Value(serverWorkoutPhase.sequence!)));

    for (final dbItem in dbWorkoutPhase.items) {
      WorkoutItemDto? remoteItem = serverWorkoutPhase.items
          .firstWhereOrNull((element) => element.id == dbItem.item.id);
      if (remoteItem == null) {
        await db.workoutDAO.deleteWorkoutItemById(dbItem.item.id);
      } else {
        await _handleDbWorkoutItemSync(dbItem, remoteItem);
      }
    }
  }

  Future<void> _handleDbWorkoutItemSync(JoinedWorkoutItemM dbWorkoutItem,
      WorkoutItemDto serverWorkoutItem) async {
    db.workoutDAO.updateWorkoutItemById(
        dbWorkoutItem.item.id,
        WorkoutItemsCompanion(
            name: Value(serverWorkoutItem.name!),
            sequence: Value(serverWorkoutItem.sequence!),
            timeCapSecs: Value(serverWorkoutItem.timeCapSecs),
            restTimeSecs: Value(serverWorkoutItem.restTimeSecs),
            rounds: Value(serverWorkoutItem.rounds),
            workModality: Value(serverWorkoutItem.workModality),
            workTimeSecs: Value(serverWorkoutItem.workTimeSecs)));

    for (final dbSet in dbWorkoutItem.sets) {
      WorkoutSetDto? remoteSet = serverWorkoutItem.sets
          .firstWhereOrNull((element) => element.id == dbSet.set.id);
      if (remoteSet == null) {
        await db.workoutDAO.deleteWorkoutSetById(dbSet.set.id);
      } else {
        await _handleDbWorkoutSetSync(dbSet.set, remoteSet);
      }
    }
  }

  Future<void> _handleDbWorkoutSetSync(
      WorkoutSetM dbWorkoutSet, WorkoutSetDto serverWorkoutSet) async {
    db.workoutDAO.updateWorkoutSetById(
        dbWorkoutSet.id,
        WorkoutSetsCompanion(
            weight: Value(serverWorkoutSet.weight),
            sequence: Value(serverWorkoutSet.sequence!),
            reps: Value(serverWorkoutSet.reps),
            distance: Value(serverWorkoutSet.distance),
            setExecutions: Value(serverWorkoutSet.setExecutions),
            exerciseId: Value(serverWorkoutSet.exerciseId!)));
  }
}
