import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/widgets/exercise_editor_screen/exercise_editor_screen_widget.dart';
import 'package:training_app/widgets/exercise_screen/bloc/exercise_list_bloc.dart';
import 'package:training_app/widgets/slidable_list_item.dart';
import 'package:training_app/widgets/list_search_widget/list_search_widget.dart';

class ExerciseListWidget extends StatefulWidget {
  @override
  _ExerciseListWidgetState createState() => _ExerciseListWidgetState();
}

class _ExerciseListWidgetState extends State<ExerciseListWidget> {
  late AutoScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    final bloc = BlocProvider.of<ExerciseListBloc>(context);
    _scrollController.addListener(() {
      if (_scrollController.offset != 0.0 &&
          _scrollController.offset ==
              _scrollController.position.maxScrollExtent &&
          !bloc.isFetching) {
        bloc.add(ExercisesFetchEvent());
      }
    });
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
    if (state is ExerciseListErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.errorMessage),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Widget _buildList(BuildContext context, ExerciseListState state) {
    final bloc = BlocProvider.of<ExerciseListBloc>(context);
    if (state is ExerciseListItemModifiedState &&
        state.type == ModificationType.creation) {
      // Remember: This add works online once per build call
      WidgetsBinding.instance!.addPostFrameCallback((_) =>
          _scrollController.scrollToIndex(state.modifiedIndex,
              duration: Duration(seconds: 1),
              preferPosition: AutoScrollPosition.middle));
    } else if (state is ExerciseListErrorState && state.exercises.isEmpty) {
      return _buildReloadButton(context, bloc, state);
    }
    return _buildListView(context, bloc, state);
  }

  Widget _buildReloadButton(BuildContext context, ExerciseListBloc bloc,
      ExerciseListErrorState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => bloc.add(ExercisesFetchEvent()),
          icon: Icon(Icons.refresh),
        ),
        const SizedBox(height: 15),
        Text(state.errorMessage, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildListView(
      BuildContext context, ExerciseListBloc bloc, ExerciseListState state) {
    return SlidableAutoCloseBehavior(
        child: RefreshIndicator(
            onRefresh: () async {
              bloc.add(ExercisesFetchEvent(reload: true));
            },
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              itemBuilder: (context, index) => AutoScrollTag(
                  key: ValueKey(index),
                  controller: _scrollController,
                  index: index,
                  highlightColor: Colors.black.withOpacity(0.1),
                  // TODO Review this null accessor ! id!
                  child: SlidableListItem(state.exercises[index].id!,
                      itemTitle: state.exercises[index].name,
                      itemSubtitle: state.exercises[index].description,
                      onDelete: (exerciseId) =>
                          bloc.add(DeleteExerciseEvent(exerciseId)),
                      onEdit: (exerciseId) => _openExerciseEditionDialog(
                          context,
                          bloc,
                          state.exercises.firstWhere(
                              (element) => exerciseId == element.id)))),
              itemCount: state.exercises.length,
            )));
  }

  void _openExerciseEditionDialog(
      BuildContext context, ExerciseListBloc bloc, Exercise exercise) {
    Navigator.of(context).push(new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ExerciseEditorScreenWidget(
            bloc,
            initialExercise: exercise,
          );
        },
        fullscreenDialog: true));
  }
}
