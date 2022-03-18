import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/widgets/exercise_list_widget/bloc/exercise_list_bloc.dart';
import 'package:training_app/widgets/exercise_list_widget/exercise_list_item.dart';
import 'package:training_app/widgets/exercise_list_widget/exercise_list_widget.dart';
import 'package:training_app/widgets/list_search_widget/list_search_widget.dart';

class ExerciseListScreenWidget extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
        child: Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: true,
                title: Text('Exercises'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context, false),
                )),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(AppRoutes.NEW_EXERCISE_SCREEN_ROUTE);
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            ),
            body: BlocProvider<ExerciseListBloc>(
              create: (_) => ExerciseListBloc()..add(ExercisesFetchEvent()),
              child: ExerciseListWidget(),
            )));
  }
}
