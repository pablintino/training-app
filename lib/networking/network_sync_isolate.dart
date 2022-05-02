import 'dart:isolate';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/isolate.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/app_config.dart';
import 'package:training_app/database/database.dart';
import 'package:training_app/networking/api_security_provider.dart';
import 'package:training_app/networking/clients.dart';
import 'package:training_app/networking/database_synchronizer.dart';
import 'package:training_app/utils/isolate_utils.dart';

class NetworkSyncIsolate {
  final ReceivePort _receiverPort;
  final Isolate _isolate;
  late SendPort _isolatePort;
  final Function(TokenUpdateData)? onTokenRefreshed;
  final Completer<NetworkSyncIsolate> _completer;

  NetworkSyncIsolate._(this._receiverPort, this._isolate, this._completer,
      {Function(TokenUpdateData)? onTokenRefreshed})
      : onTokenRefreshed = onTokenRefreshed {
    this._receiverPort.asBroadcastStream().listen(_receiverHandler);
  }

  static Future<NetworkSyncIsolate> createIsolate(DriftIsolate driftIsolate,
      {Function(TokenUpdateData)? onTokenRefreshed}) async {
    // App path can only be retrieved in main Isolate. Get it just before spawn
    // and pass the path as argument
    final configPath = await AppConfigLoader.getPath();
    final completer = Completer<NetworkSyncIsolate>();
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
        _entitiesSyncTask,
        _IsolateSpawnPayload(
            receivePort.sendPort, driftIsolate.connectPort, configPath));
    NetworkSyncIsolate._(receivePort, isolate, completer,
        onTokenRefreshed: onTokenRefreshed);

    return completer.future;
  }

  void _receiverHandler(dynamic message) {
    if (message is _IsolateSourceCommand) {
      if (message.commandType ==
              _IsolateSourceCommandType.AUTH_ACCESS_REFRESHED &&
          onTokenRefreshed != null) {
        this.onTokenRefreshed!(message.payload as TokenUpdateData);
      } else if (message.commandType ==
          _IsolateSourceCommandType.INIT_SEND_PORT) {
        if (_completer.isCompleted) {
          throw "Already completed";
        }
        _isolatePort = message.payload as SendPort;
        _completer.complete(this);
      }
    }
  }

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

Future<void> _entitiesSyncTask(_IsolateSpawnPayload initPayload) async {
  final commandPort = ReceivePort();
  initPayload.parentSendPort.send(_IsolateSourceCommand(
      _IsolateSourceCommandType.INIT_SEND_PORT,
      payload: commandPort.sendPort));

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

enum _IsolateSourceCommandType { AUTH_ACCESS_REFRESHED, INIT_SEND_PORT }

class _IsolateSourceCommand {
  final _IsolateSourceCommandType commandType;
  final Object? payload;

  _IsolateSourceCommand(this.commandType, {this.payload});
}

class _IsolateSpawnPayload {
  final SendPort parentSendPort;
  final String configPath;
  final SendPort driftPort;

  _IsolateSpawnPayload(this.parentSendPort, this.driftPort, this.configPath);
}
