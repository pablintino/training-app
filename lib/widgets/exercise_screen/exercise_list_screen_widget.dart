import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/widgets/exercise_editor_screen/exercise_editor_screen_widget.dart';
import 'package:training_app/widgets/exercise_screen/bloc/exercise_list_bloc.dart';
import 'package:training_app/widgets/exercise_screen/exercise_list_widget.dart';

class ExerciseListScreenWidget extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: BlocProvider<ExerciseListBloc>(
          create: (_) => ExerciseListBloc()..add(ExercisesFetchEvent()),
          child: _ScaffoldedExerciseListWidget(),
        ));
  }
}

class _ScaffoldedExerciseListWidget extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<ExerciseListBloc>(context);
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text('Exercises'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _openExerciseCreationDialog(context, _bloc);
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
        body: ExerciseListWidget());
  }

  void _openExerciseCreationDialog(
      BuildContext context, ExerciseListBloc bloc) {
    Navigator.of(context).push(new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ExerciseEditorScreenWidget(bloc);
        },
        fullscreenDialog: true));
  }
}
