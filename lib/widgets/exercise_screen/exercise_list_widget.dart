import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/widgets/exercise_screen/bloc/exercise_list_bloc.dart';
import 'package:training_app/widgets/exercise_screen/exercise_list_item.dart';
import 'package:training_app/widgets/list_search_widget/list_search_widget.dart';

class ExerciseListWidget extends StatefulWidget {
  @override
  _ExerciseListWidgetState createState() => _ExerciseListWidgetState();
}

class _ExerciseListWidgetState extends State<ExerciseListWidget> {
  final List<Exercise> _exercises = [];
  late AutoScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
  }

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
          hintText: "Search exercise..."),
      Expanded(
        child: BlocConsumer<ExerciseListBloc, ExerciseListState>(
          listener: (ctx, state) => _onStateChange(ctx, state),
          builder: (ctx, state) => _buildList(ctx, state),
        ),
      )
    ]));
  }

  void _onStateChange(BuildContext context, ExerciseListState state) {
    if (state is ExerciseListLoadingSuccessState && state.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No more exercises'),
        duration: Duration(seconds: 2),
      ));
    } else if (state is ExerciseListLoadingErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.error),
        duration: Duration(seconds: 2),
      ));
      BlocProvider.of<ExerciseListBloc>(context).isFetching = false;
    }
  }

  Widget _buildList(BuildContext context, ExerciseListState state) {
    final bloc = BlocProvider.of<ExerciseListBloc>(context);
    if (state is ExerciseListLoadingSuccessState) {
      _exercises.addAll(state.exercises);
      bloc.isFetching = false;
    } else if (state is ExerciseListReloadSuccessState) {
      _exercises.clear();
      _exercises.addAll(state.exercises);
      bloc.isFetching = false;
    } else if (state is ExerciseCreationSuccessState) {
      _exercises.clear();
      _exercises.addAll(state.reloadedExercises);
      bloc.isFetching = false;
      // Remember: This add works online once per build call
      WidgetsBinding.instance!.addPostFrameCallback((_) =>
          _scrollController.scrollToIndex(state.newIndex,
              duration: Duration(seconds: 1),
              preferPosition: AutoScrollPosition.middle));
    } else if (state is ExerciseListLoadingErrorState && _exercises.isEmpty) {
      return _buildReloadButton(context, bloc, state);
    }
    return _buildListView(bloc);
  }

  Column _buildReloadButton(BuildContext context, ExerciseListBloc bloc, ExerciseListLoadingErrorState state) {
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

  ListView _buildListView(ExerciseListBloc bloc) {
    return ListView.builder(
      controller: _scrollController
        ..addListener(() {
          if (_scrollController.offset ==
                  _scrollController.position.maxScrollExtent &&
              !bloc.isFetching) {
            bloc.isFetching = true;
            bloc.add(ExercisesFetchEvent());
          }
        }),
      itemBuilder: (context, index) => AutoScrollTag(
          key: ValueKey(index),
          controller: _scrollController,
          index: index,
          highlightColor: Colors.black.withOpacity(0.1),
          child: ExerciseListItem(_exercises[index])),
      itemCount: _exercises.length,
    );
  }
}
