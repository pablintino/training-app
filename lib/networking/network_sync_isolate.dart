import 'dart:isolate';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/isolate.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/app_config.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/networking/clients.dart';
import 'package:training_app/networking/database_synchronizer.dart';
import 'package:training_app/utils/isolate_utils.dart';

class NetworkSyncIsolate {
  final ReceivePort _receiverPort;
  final Isolate _isolate;
  final SendPort _isolatePort;

  NetworkSyncIsolate(this._receiverPort, this._isolatePort, this._isolate);

  Future<void> launchExercisesSync() =>
      _launchSyncRequest(DatabaseSyncRequestType.EXERCISES);

  Future<void> launchWorkoutsSync() =>
      _launchSyncRequest(DatabaseSyncRequestType.WORKOUTS);

  Future<void> launchAllEntitiesSync() =>
      _launchSyncRequest(DatabaseSyncRequestType.ALL);

  Future<bool> _launchSyncRequest(DatabaseSyncRequestType requestType) {
    return singleResponseFuture<bool>(
        (port) => _isolatePort.send(DatabaseSyncRequest(requestType, port)));
  }

  terminate() {
    _isolatePort.send(null);
  }
}

Future<NetworkSyncIsolate> createNetworkIsolate(
    DriftIsolate driftIsolate) async {
  // App path can only be retrieved in main Isolate. Get it just before spawn
  // and pass the path as argument
  final configPath = await AppConfigLoader.getPath();

  final p = ReceivePort();
  return await Isolate.spawn(
          _entitiesSyncTask,
          _IsolateSpawnPayload(
              p.sendPort, driftIsolate.connectPort, configPath))
      .then((isolate) async {
    final sendPort = await p.first as SendPort;
    return NetworkSyncIsolate(p, sendPort, isolate);
  });
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

typedef _AsyncHandlingCallback = Future<void> Function(ReceivePort);

class _IsolateSpawnPayload {
  final SendPort parentSendPort;
  final String configPath;
  final SendPort driftPort;

  _IsolateSpawnPayload(this.parentSendPort, this.driftPort, this.configPath);
}
