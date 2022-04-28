import 'dart:isolate';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/isolate.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/app_config.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/database/database_isolate.dart';
import 'package:training_app/networking/clients.dart';
import 'package:training_app/networking/database_synchronizer.dart';
import 'package:training_app/utils/isolate_utils.dart';

class NetworkSyncIsolate {
  final ReceivePort receiverPort;
  final SendPort isolatePort;

  NetworkSyncIsolate(this.receiverPort, this.isolatePort);

  Future<void> launchExercisesSync() {
    return singleResponseFuture<bool>((port) => isolatePort
        .send(DatabaseSyncRequest(DatabaseSyncRequestType.EXERCISES, port)));
  }

  Future<void> launchWorkoutsSync() {
    return singleResponseFuture<bool>((port) => isolatePort
        .send(DatabaseSyncRequest(DatabaseSyncRequestType.WORKOUTS, port)));
  }

  terminate() {
    isolatePort.send(null);
  }
}

Future<NetworkSyncIsolate> createNetworkIsolate(
    DriftIsolate driftIsolate) async {
  final p = ReceivePort();
  final configPath = await AppConfigLoader.getPath();
  return Isolate.spawn(
          _entitiesSyncTask,
          _IsolateSpawnPayload(
              p.sendPort, driftIsolate.connectPort, configPath))
      .then((value) async => await p.first as SendPort)
      .then((value) => NetworkSyncIsolate(p, value));
}

Future<void> _entitiesSyncTask(_IsolateSpawnPayload initPayload) async {
  final commandPort = ReceivePort();
  initPayload.parentSendPort.send(commandPort.sendPort);

  await _runUnderIoCScope(initPayload, commandPort, _isolateHandlingLoop);

  Isolate.exit();
}

Future<void> _isolateHandlingLoop(ReceivePort commandPort) async {
  final dbSync = GetIt.instance<DatabaseSynchronizer>();
  await for (final message in commandPort) {
    if (message is DatabaseSyncRequest) {
      try {
        await dbSync.handleSyncRequest(message);
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

void _registerInversionOfControlInstances(_IsolateSpawnPayload initPayload) {
  GetIt.instance.registerSingletonAsync<AppDatabase>(() async =>
      DriftIsolate.fromConnectPort(initPayload.driftPort)
          .connect()
          .then((connection) => AppDatabase.connect(connection)));

  GetIt.instance.registerSingletonAsync<AppConfig>(
      () async => AppConfigLoader.create(path: initPayload.configPath));

  GetIt.instance.registerSingletonWithDependencies<Dio>(() {
    var dio = Dio();
    dio.options.baseUrl = GetIt.instance<AppConfig>().apiUrl;
    return dio;
  }, dependsOn: [AppConfig]);

  GetIt.instance.registerSingletonWithDependencies<ExerciseClient>(
      () => ExerciseClient(),
      dependsOn: [Dio]);
  GetIt.instance.registerSingletonWithDependencies<WorkoutClient>(
      () => WorkoutClient(),
      dependsOn: [Dio]);

  GetIt.instance.registerSingletonWithDependencies(() => DatabaseSynchronizer(),
      dependsOn: [ExerciseClient, WorkoutClient, AppDatabase]);
}

Future<void> _runUnderIoCScope(_IsolateSpawnPayload initPayload,
    ReceivePort commandPort, _AsyncHandlingCallback function) async {
  _registerInversionOfControlInstances(initPayload);

  await GetIt.instance.allReady();
  final db = GetIt.instance<AppDatabase>();

  try {
    await function(commandPort);
  } finally {
    await db.close();
  }
}

typedef _AsyncHandlingCallback = Future<void> Function(ReceivePort);

class _IsolateSpawnPayload {
  final SendPort parentSendPort;
  final String configPath;
  final SendPort driftPort;

  _IsolateSpawnPayload(this.parentSendPort, this.driftPort, this.configPath);
}
