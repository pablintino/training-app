import 'dart:isolate';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/isolate.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  late ApiSecurityProvider _apiSecurityProvider;
  late SendPort _isolatePort;
  final Completer<NetworkSyncIsolate> _completer;

  NetworkSyncIsolate._(this._receiverPort, this._isolate, this._completer,
      {ApiSecurityProvider? apiSecurityProvider}) {
    this._apiSecurityProvider =
        apiSecurityProvider ?? GetIt.instance<ApiSecurityProvider>();

    // Send to isolate token refreshes
    this._apiSecurityProvider.setOnTokenRefresh((tokenData) => this
        ._isolatePort
        .send(_IsolateCommand(_IsolateCommandType.AUTH_ACCESS_REFRESHED,
            payload: tokenData)));

    this._receiverPort.asBroadcastStream().listen(_receiverHandler);
  }

  static Future<NetworkSyncIsolate> createIsolate(DriftIsolate driftIsolate,
      {Function(TokenUpdateData)? onTokenRefreshed,
      ApiSecurityProvider? apiSecurityProvider}) async {
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
        apiSecurityProvider: apiSecurityProvider);

    return completer.future;
  }

  // Handler for processing messages that comes from the isolate to the main
  void _receiverHandler(dynamic message) {
    if (message is _IsolateSourceCommand) {
      if (message.commandType ==
          _IsolateSourceCommandType.AUTH_ACCESS_REFRESHED) {
        final tokenData = message.payload as TokenUpdateData;
        // Update the main isolate security provider
        this
            ._apiSecurityProvider
            .externallySetTokens(tokenData.accessToken, tokenData.refreshToken);
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
  final apiSecurityProvider = GetIt.instance<ApiSecurityProvider>();
  await for (final message in commandPort) {
    if (message is DatabaseSyncRequest) {
      try {
        await dbSync.handleSyncRequest(message);
      } catch (e) {
        print('Exception handler called on database sync request');
      }
      // TODO notify the caller if something gone wrong
      message.sendPort.send(true);
    } else if (message is _IsolateCommand) {
      _handleCommandMessage(message, apiSecurityProvider);
    } else if (message == null) {
      break;
    }
  }
}

void _handleCommandMessage(
    _IsolateCommand message, ApiSecurityProvider apiSecurityProvider) {
  try {
    if (message.commandType == _IsolateCommandType.AUTH_ACCESS_REFRESHED) {
      final tokenData = message.payload as TokenUpdateData;
      // Update the network isolate isolate security provider with the tokens
      // from the main isolate
      apiSecurityProvider.externallySetTokens(
          tokenData.accessToken, tokenData.refreshToken);
    }
  } catch (e) {
    print('Exception handler called command message handling');
  }
}

Future<void> _runUnderIoCScope(_IsolateSpawnPayload initPayload,
    ReceivePort commandPort, _AsyncHandlingCallback function) async {
  await _registerInversionOfControlInstances(initPayload);

  final db = GetIt.instance<AppDatabase>();

  // Set security callback token update handler
  _registerTokenUpdateHandler(initPayload);

  try {
    await function(commandPort);
  } finally {
    await db.close();
  }
}

void _registerTokenUpdateHandler(_IsolateSpawnPayload initPayload) {
  final apiSecurityProvider = GetIt.instance<ApiSecurityProvider>();
  apiSecurityProvider.setOnTokenRefresh((tokenData) =>
      initPayload.parentSendPort.send(_IsolateSourceCommand(
          _IsolateSourceCommandType.AUTH_ACCESS_REFRESHED,
          payload: tokenData)));
}

Future<void> _registerInversionOfControlInstances(
    _IsolateSpawnPayload initPayload) async {
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

  GetIt.instance.registerSingletonWithDependencies<ApiSecurityProvider>(
      () => ApiSecurityProvider(false,
          appAuth: FlutterAppAuth(), secureStorage: FlutterSecureStorage()),
      dependsOn: [AppConfig]);

  GetIt.instance.registerSingletonWithDependencies<ExerciseClient>(
      () => ExerciseClient(),
      dependsOn: [Dio]);
  GetIt.instance.registerSingletonWithDependencies<WorkoutClient>(
      () => WorkoutClient(),
      dependsOn: [Dio]);

  GetIt.instance.registerSingletonWithDependencies(() => DatabaseSynchronizer(),
      dependsOn: [ExerciseClient, WorkoutClient, AppDatabase]);

  await GetIt.instance.allReady();
}

typedef _AsyncHandlingCallback = Future<void> Function(ReceivePort);

enum _IsolateSourceCommandType { AUTH_ACCESS_REFRESHED, INIT_SEND_PORT }
enum _IsolateCommandType { AUTH_ACCESS_REFRESHED }

class _IsolateSourceCommand {
  final _IsolateSourceCommandType commandType;
  final Object? payload;

  _IsolateSourceCommand(this.commandType, {this.payload});
}

class _IsolateCommand {
  final _IsolateCommandType commandType;
  final Object? payload;

  _IsolateCommand(this.commandType, {this.payload});
}

class _IsolateSpawnPayload {
  final SendPort parentSendPort;
  final String configPath;
  final SendPort driftPort;

  _IsolateSpawnPayload(this.parentSendPort, this.driftPort, this.configPath);
}
