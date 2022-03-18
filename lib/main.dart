import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:training_app/app_config.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/blocs/auth/auth_bloc.dart';
import 'package:training_app/repositories/exercises_repository.dart';
import 'package:training_app/repositories/user_auth_repository.dart';
import 'package:training_app/widgets/exercise_list_widget/exercise_list_screen_widget.dart';
import 'package:training_app/widgets/login_screen_widget/login_screen_widget.dart';
import 'package:training_app/widgets/main_app_widget/main_app_widget.dart';
import 'package:training_app/widgets/new_exercise_screen_widget/new_exercise_widget.dart';

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
            AppRoutes.LOGIN_SCREEN_ROUTE: (context) => LoginScreenWidget(),
            AppRoutes.EXERCISES_LISTS_SCREEN_ROUTE: (context) =>
                ExerciseListScreenWidget(),
            AppRoutes.NEW_EXERCISE_SCREEN_ROUTE: (context) =>
                NewExerciseScreenWidget(),
          },
          home: MainAppWidget(),
        ));
  }
}

Future<void> setup() async {
  await AppConfigLoader().init();
  GetIt.instance.registerSingleton<ExercisesRepository>(ExercisesRepository());
  GetIt.instance.registerSingleton<UserAuthRepository>(UserAuthRepository());
}
