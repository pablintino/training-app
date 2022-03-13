import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/widgets/drawer_navigation_widget/drawer_navigation_widget.dart';
import 'package:training_app/widgets/exercise_list_widget/bloc/exercise_list_bloc.dart';
import 'package:training_app/widgets/exercise_list_widget/exercise_list_item.dart';

class ExerciseListWidget extends StatefulWidget {
  @override
  _ExerciseListWidgetState createState() => _ExerciseListWidgetState();
}

class _ExerciseListWidgetState extends State<ExerciseListWidget> {
  final List<Exercise> _exercises = [];
  final ScrollController _scrollController = ScrollController();
  final bloc = ExerciseListBloc()..add(ExercisesFetchEvent());

  @override
  Widget build(BuildContext context) {
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
          Navigator.of(context).pushNamed('/exercises/new');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: BlocConsumer<ExerciseListBloc, ExerciseListState>(
          bloc: bloc,
          listener: (context, state) {
            if (state is ExerciseListLoadingState) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ExerciseListLoadingSuccessState &&
                state.exercises.isEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('No more exercises')));
            } else if (state is ExerciseListLoadingErrorState) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error)));
              bloc.isFetching = false;
            }
            return;
          },
          builder: (context, state) {
            if (state is ExerciseListInitialState ||
                state is ExerciseListLoadingState && _exercises.isEmpty) {
              return CircularProgressIndicator();
            } else if (state is ExerciseListLoadingSuccessState) {
              _exercises.addAll(state.exercises);
              bloc.isFetching = false;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            } else if (state is ExerciseListLoadingErrorState &&
                _exercises.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      bloc.isFetching = true;
                      bloc.add(ExercisesFetchEvent());
                    },
                    icon: Icon(Icons.refresh),
                  ),
                  const SizedBox(height: 15),
                  Text(state.error, textAlign: TextAlign.center),
                ],
              );
            }
            return ListView.separated(
              controller: _scrollController
                ..addListener(() {
                  if (_scrollController.offset ==
                          _scrollController.position.maxScrollExtent &&
                      !bloc.isFetching) {
                    bloc.isFetching = true;
                    bloc.add(ExercisesFetchEvent());
                  }
                }),
              itemBuilder: (context, index) =>
                  ExerciseListItem(_exercises[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemCount: _exercises.length,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
