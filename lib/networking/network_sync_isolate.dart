import 'dart:isolate';
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:training_app/app_config.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/database/database_isolate.dart';
import 'package:training_app/database/join_entities.dart';
import 'package:training_app/networking/clients.dart';
import 'package:training_app/networking/entities/exercise_dto.dart';
import 'package:training_app/networking/entities/workout_dtos.dart';
import 'package:training_app/utils/isolate_utils.dart';
import 'package:tuple/tuple.dart';

class NetworkSyncIsolate {
  final ReceivePort receiverPort;
  final SendPort isolatePort;

  NetworkSyncIsolate(this.receiverPort, this.isolatePort);

  Future<void> launchExercisesSync() {
    return singleResponseFuture<bool>((port) =>
        isolatePort.send(_SyncRequest(_SyncRequestType.EXERCISES, port)));
  }

  Future<void> launchWorkoutsSync() {
    return singleResponseFuture<bool>((port) =>
        isolatePort.send(_SyncRequest(_SyncRequestType.WORKOUTS, port)));
  }

  terminate() {
    isolatePort.send(null);
  }
}

Future<NetworkSyncIsolate> createNetworkIsolate(
    DriftIsolate driftIsolate) async {
  final p = ReceivePort();
  final configPath = await AppConfigLoader.getPath();
  await Isolate.spawn(_entitiesSyncTask,
      _IsolateSpawnPayload(p.sendPort, driftIsolate.connectPort, configPath));

  final isolatePort = await p.first as SendPort;
  return NetworkSyncIsolate(p, isolatePort);
}

Future<void> _entitiesSyncTask(_IsolateSpawnPayload initPayload) async {
  final commandPort = ReceivePort();
  initPayload.parentSendPort.send(commandPort.sendPort);

  final db = AppDatabase.connect(
      isolateConnect(DriftIsolate.fromConnectPort(initPayload.driftPort)));
  final appConfig = await AppConfigLoader.create(path: initPayload.configPath);
  final dbSync = _DBSynchronizer(commandPort, db, appConfig);
  await dbSync.loop();

  await db.close();
  Isolate.exit();
}

class _DBSynchronizer {
  final ReceivePort _commandPort;
  final AppDatabase _db;
  final AppConfig _appConfig;
  final Dio _dio;
  late ExerciseClient _exerciseClient;
  late WorkoutClient _workoutClient;

  _DBSynchronizer(this._commandPort, this._db, this._appConfig)
      : _dio = createDioClient(_appConfig) {
    _exerciseClient = ExerciseClient(_dio);
    _workoutClient = WorkoutClient(_dio);
  }

  Future<void> loop() async {
    await for (final message in _commandPort) {
      if (message is _SyncRequest) {
        try {
          await _handleSyncRequest(message);
        } catch (e) {
          print('Exception handler called');
        }
        // TODO notify the caller if something gone wrong
        message.sendPort.send(true);
      } else if (message == null) {
        break;
      }
    }
  }

  Future<void> _handleSyncRequest(_SyncRequest request) async {
    if (request.requestType == _SyncRequestType.EXERCISES) {
      return _handleExercisesSync();
    } else if (request.requestType == _SyncRequestType.WORKOUTS) {
      return _handleWorkoutsSync();
    }
    return null;
  }

  Future<void> _handleExercisesSync() async {
    final dbExercises = await _db.exerciseDAO.getAllExercises();

    final exercises = await _exerciseClient.getExercises(bulk: false);
    for (final dbExercise in dbExercises) {
      ExerciseDto? remoteExercise =
          exercises.firstWhereOrNull((element) => element.id == dbExercise.id);
      if (remoteExercise == null) {
        await _db.exerciseDAO.deleteById(dbExercise.id);
      } else {
        await _db.exerciseDAO.updateById(
            dbExercise.id,
            ExercisesCompanion(
                name: Value(remoteExercise.name!),
                description: Value(remoteExercise.description)));
      }
    }

    for (final remoteExercise in exercises) {
      if (await _db.exerciseDAO.getById(remoteExercise.id!) == null) {
        await _db.exerciseDAO.insertExercise(ExercisesCompanion(
            id: Value(remoteExercise.id!),
            name: Value(remoteExercise.name!),
            description: Value(remoteExercise.description)));
      }
    }
  }

  Future<void> _handleWorkoutsSync() async {
    final serverWorkouts =
        await _workoutClient.getWorkouts(bulk: false, fat: true);
    final dbWorkouts = await _db.workoutDAO.getAllJoinedWorkouts();
    for (final dbWorkout in dbWorkouts) {
      WorkoutDto? remoteWorkout = serverWorkouts
          .firstWhereOrNull((element) => element.id == dbWorkout.workout.id);
      if (remoteWorkout == null) {
        await _db.workoutDAO.deleteWorkoutById(dbWorkout.workout.id);
      } else {
        await _handleDbWorkoutSync(dbWorkout, remoteWorkout);
      }
    }

    for (final remoteWorkout in serverWorkouts) {
      if (await _db.workoutDAO.getWorkoutById(remoteWorkout.id!) == null) {
        await _db.workoutDAO.insertWorkout(WorkoutsCompanion(
            id: Value(remoteWorkout.id!),
            name: Value(remoteWorkout.name!),
            description: Value(remoteWorkout.description)));
      }
    }

    for (final remoteSession in serverWorkouts.expand((element) => element
        .sessions
        .map((e) => Tuple2<int, WorkoutSessionDto>(element.id!, e)))) {
      if (await _db.workoutDAO.getWorkoutSessionById(remoteSession.item2.id!) ==
          null) {
        await _db.workoutDAO.insertWorkoutSession(WorkoutSessionsCompanion(
            id: Value(remoteSession.item2.id!),
            workoutId: Value(remoteSession.item1),
            weekDay: Value(remoteSession.item2.weekDay!),
            week: Value(remoteSession.item2.week!)));
      }
    }

    for (final remotePhase in serverWorkouts
        .expand((element) => element.sessions)
        .expand((element) => element.phases
            .map((e) => Tuple2<int, WorkoutPhaseDto>(element.id!, e)))) {
      if (await _db.workoutDAO.getWorkoutPhaseById(remotePhase.item2.id!) ==
          null) {
        await _db.workoutDAO.insertWorkoutPhase(WorkoutPhasesCompanion(
            id: Value(remotePhase.item2.id!),
            sequence: Value(remotePhase.item2.sequence!),
            name: Value(remotePhase.item2.name!),
            workoutSessionId: Value(remotePhase.item1)));
      }
    }

    for (final remoteItem in serverWorkouts
        .expand((element) => element.sessions)
        .expand((element) => element.phases)
        .expand((element) => element.items
            .map((e) => Tuple2<int, WorkoutItemDto>(element.id!, e)))) {
      if (await _db.workoutDAO.getWorkoutItemById(remoteItem.item2.id!) ==
          null) {
        await _db.workoutDAO.insertWorkoutItem(WorkoutItemsCompanion(
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

    for (final remoteSet in serverWorkouts
        .expand((element) => element.sessions)
        .expand((element) => element.phases)
        .expand((element) => element.items)
        .expand((element) => element.sets
            .map((e) => Tuple2<int, WorkoutSetDto>(element.id!, e)))) {
      if (await _db.workoutDAO.getWorkoutSetById(remoteSet.item2.id!) == null) {
        await _db.workoutDAO.insertWorkoutSet(WorkoutSetsCompanion(
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
    _db.workoutDAO.updateWorkoutById(
        dbWorkout.workout.id,
        WorkoutsCompanion(
            name: Value(serverWorkout.name!),
            description: Value(serverWorkout.description)));

    for (final dbSession in dbWorkout.sessions) {
      WorkoutSessionDto? remoteSession = serverWorkout.sessions
          .firstWhereOrNull((element) => element.id == dbSession.session.id);
      if (remoteSession == null) {
        await _db.workoutDAO.deleteWorkoutSessionById(dbSession.session.id);
      } else {
        await _handleDbWorkoutSessionSync(dbSession, remoteSession);
      }
    }
  }

  Future<void> _handleDbWorkoutSessionSync(
      JoinedWorkoutSessionM dbWorkoutSession,
      WorkoutSessionDto serverWorkoutSession) async {
    _db.workoutDAO.updateWorkoutSessionById(
        dbWorkoutSession.session.id,
        WorkoutSessionsCompanion(
            weekDay: Value(serverWorkoutSession.weekDay!),
            week: Value(serverWorkoutSession.week!)));

    for (final dbPhase in dbWorkoutSession.phases) {
      WorkoutPhaseDto? remotePhase = serverWorkoutSession.phases
          .firstWhereOrNull((element) => element.id == dbPhase.phase.id);
      if (remotePhase == null) {
        await _db.workoutDAO.deleteWorkoutPhaseById(dbPhase.phase.id);
      } else {
        await _handleDbWorkoutPhaseSync(dbPhase, remotePhase);
      }
    }
  }

  Future<void> _handleDbWorkoutPhaseSync(JoinedWorkoutPhaseM dbWorkoutPhase,
      WorkoutPhaseDto serverWorkoutPhase) async {
    _db.workoutDAO.updateWorkoutPhaseById(
        dbWorkoutPhase.phase.id,
        WorkoutPhasesCompanion(
            name: Value(serverWorkoutPhase.name!),
            sequence: Value(serverWorkoutPhase.sequence!)));

    for (final dbItem in dbWorkoutPhase.items) {
      WorkoutItemDto? remoteItem = serverWorkoutPhase.items
          .firstWhereOrNull((element) => element.id == dbItem.item.id);
      if (remoteItem == null) {
        await _db.workoutDAO.deleteWorkoutItemById(dbItem.item.id);
      } else {
        await _handleDbWorkoutItemSync(dbItem, remoteItem);
      }
    }
  }

  Future<void> _handleDbWorkoutItemSync(JoinedWorkoutItemM dbWorkoutItem,
      WorkoutItemDto serverWorkoutItem) async {
    _db.workoutDAO.updateWorkoutItemById(
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
          .firstWhereOrNull((element) => element.id == dbSet.id);
      if (remoteSet == null) {
        await _db.workoutDAO.deleteWorkoutSetById(dbSet.id);
      } else {
        await _handleDbWorkoutSetSync(dbSet, remoteSet);
      }
    }
  }

  Future<void> _handleDbWorkoutSetSync(
      WorkoutSetM dbWorkoutSet, WorkoutSetDto serverWorkoutSet) async {
    _db.workoutDAO.updateWorkoutSetById(
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

enum _SyncRequestType { EXERCISES, WORKOUTS }

class _SyncRequest {
  final _SyncRequestType requestType;
  final SendPort sendPort;

  _SyncRequest(this.requestType, this.sendPort);
}

class _IsolateSpawnPayload {
  final SendPort parentSendPort;
  final String configPath;
  final SendPort driftPort;

  _IsolateSpawnPayload(this.parentSendPort, this.driftPort, this.configPath);
}
