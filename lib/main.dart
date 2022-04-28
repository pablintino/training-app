import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/app_config.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/blocs/auth/auth_bloc.dart';
import 'package:training_app/database/database_isolate.dart';
import 'package:training_app/networking/clients.dart';
import 'package:training_app/networking/network_sync_isolate.dart';
import 'package:training_app/repositories/exercises_repository.dart';
import 'package:training_app/repositories/user_auth_repository.dart';
import 'package:training_app/repositories/workouts_repository.dart';
import 'package:training_app/widgets/exercise_screen/exercise_list_screen_widget.dart';
import 'package:training_app/widgets/login_screen_widget/login_screen_widget.dart';
import 'package:training_app/widgets/main_app_widget/main_app_widget.dart';
import 'package:training_app/widgets/workout_detail_screen_widget/workout_detail_screen_widget.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/workout_session_detail_screen_widget.dart';
import 'database/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setup().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (BuildContext context) =>
                  AuthBloc()..add(InitAppAuthEvent())),
        ],
        child: MaterialApp(
          title: 'Pablintino Training App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          routes: {
            AppRoutes.DEFAULT_ROUTE: (context) => LoginScreenWidget(),
            AppRoutes.LOGIN_SCREEN_ROUTE: (context) => LoginScreenWidget(),
            AppRoutes.HOME_SCREEN_ROUTE: (context) => MainAppWidget(),
            AppRoutes.EXERCISES_LISTS_SCREEN_ROUTE: (context) =>
                ExerciseListScreenWidget(),
            AppRoutes.WORKOUTS_SESSIONS_DETAILS_SCREEN_ROUTE: (context) =>
                WorkoutSessionScreenWidget(),
            AppRoutes.WORKOUTS_WORKOUT_DETAILS_SCREEN_ROUTE: (context) =>
                WorkoutDetailsScreenWidget()
          },
        ));
  }
}

Future<void> setup() async {
  GetIt.instance
      .registerSingletonAsync<AppConfig>(() async => AppConfigLoader.create());

  final driftIsolate = await createDriftIsolate();
  GetIt.instance.registerSingletonAsync<AppDatabase>(() async => driftIsolate
      .connect()
      .then((connection) => AppDatabase.connect(connection)));

  GetIt.instance.registerSingletonAsync<NetworkSyncIsolate>(
      () async => createNetworkIsolate(driftIsolate));

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

  GetIt.instance.registerSingletonWithDependencies<ExercisesRepository>(
      () => ExercisesRepository(),
      dependsOn: [ExerciseClient, AppConfig, NetworkSyncIsolate]);

  GetIt.instance.registerSingletonWithDependencies<WorkoutRepository>(
      () => WorkoutRepository(),
      dependsOn: [WorkoutClient, AppConfig, NetworkSyncIsolate]);

  GetIt.instance.registerSingletonWithDependencies<UserAuthRepository>(
      () => UserAuthRepository(),
      dependsOn: [AppConfig]);

  await GetIt.instance.allReady();
}
