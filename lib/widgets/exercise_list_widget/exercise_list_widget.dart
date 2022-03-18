import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/widgets/exercise_list_widget/bloc/exercise_list_bloc.dart';
import 'package:training_app/widgets/exercise_list_widget/exercise_list_item.dart';
import 'package:training_app/widgets/list_search_widget/list_search_widget.dart';

class ExerciseListWidget extends StatefulWidget {
  @override
  _ExerciseListWidgetState createState() => _ExerciseListWidgetState();
}

class _ExerciseListWidgetState extends State<ExerciseListWidget> {
  final List<Exercise> _exercises = [];
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      ListSearchWidget(
          text: 'text',
          onChanged: (filterValue) => {
                BlocProvider.of<ExerciseListBloc>(context)
                    .add(SearchFilterUpdateFetchEvent(filterValue))
              },
          hintText: "hint"),
      Expanded(
        child: BlocConsumer<ExerciseListBloc, ExerciseListState>(
          listener: (ctx, state) => _onStateChange(ctx, state),
          builder: (ctx, state) => _buildList(ctx, state),
        ),
      )
    ]));
  }

  void _onStateChange(BuildContext context, ExerciseListState state) {
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
      BlocProvider.of<ExerciseListBloc>(context).isFetching = false;
    }
  }

  Widget _buildList(BuildContext context, ExerciseListState state) {
    final bloc = BlocProvider.of<ExerciseListBloc>(context);
    if (state is ExerciseListInitialState ||
        state is ExerciseListLoadingState && _exercises.isEmpty) {
      return CircularProgressIndicator();
    } else if (state is ExerciseListLoadingSuccessState) {
      _exercises.addAll(state.exercises);
      bloc.isFetching = false;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } else if (state is ExerciseListReloadSuccessState) {
      _exercises.clear();
      _exercises.addAll(state.exercises);
      bloc.isFetching = false;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } else if (state is ExerciseListLoadingErrorState && _exercises.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              BlocProvider.of<ExerciseListBloc>(context).isFetching = true;
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
      itemBuilder: (context, index) => ExerciseListItem(_exercises[index]),
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemCount: _exercises.length,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
