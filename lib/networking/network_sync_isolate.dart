import 'dart:isolate';
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:training_app/app_config.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/database/database_isolate.dart';
import 'package:training_app/networking/clients.dart';
import 'package:training_app/networking/entities/exercise_dto.dart';
import 'package:training_app/utils/isolate_utils.dart';

class NetworkSyncIsolate {
  final ReceivePort receiverPort;
  final SendPort isolatePort;

  NetworkSyncIsolate(this.receiverPort, this.isolatePort);

  Future<void> launchExercisesSync() {
    return singleResponseFuture<bool>((port) =>
        isolatePort.send(_SyncRequest(_SyncRequestType.EXERCISES, port)));
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

  _DBSynchronizer(this._commandPort, this._db, this._appConfig)
      : _dio = createDioClient(_appConfig) {
    _exerciseClient = ExerciseClient(_dio);
  }

  Future<void> loop() async {
    await for (final message in _commandPort) {
      if (message is _SyncRequest) {
        await _handleSyncRequest(message);
        message.sendPort.send(true);
      } else if (message == null) {
        break;
      }
    }
  }

  Future<void> _handleSyncRequest(_SyncRequest request) async {
    if (request.requestType == _SyncRequestType.EXERCISES) {
      return _handleExercisesSync();
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
        _db.exerciseDAO.deleteById(dbExercise.id);
      } else {
        _db.exerciseDAO.updateById(
            dbExercise.id,
            ExercisesCompanion(
                name: Value(remoteExercise.name!),
                description: Value(remoteExercise.description)));
      }
    }

    for (final remoteExercise in exercises) {
      if (await _db.exerciseDAO.getById(remoteExercise.id!) == null) {
        _db.exerciseDAO.insertExercise(ExercisesCompanion(
            id: Value(remoteExercise.id!),
            name: Value(remoteExercise.name!),
            description: Value(remoteExercise.description)));
      }
    }
  }
}

enum _SyncRequestType { EXERCISES }

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
