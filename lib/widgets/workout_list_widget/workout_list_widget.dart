import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/widgets/list_search_widget/list_search_widget.dart';
import 'package:training_app/widgets/simple_list_item.dart';
import 'package:training_app/widgets/workout_detail_screen_widget/workout_detail_screen_widget.dart';
import 'package:training_app/widgets/workout_list_widget/bloc/workout_list_bloc.dart';

class WorkoutListWidget extends StatefulWidget {
  @override
  _WorkoutListWidgetState createState() => _WorkoutListWidgetState();
}

class _WorkoutListWidgetState extends State<WorkoutListWidget> {
  late AutoScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    final bloc = BlocProvider.of<WorkoutListBloc>(context);
    _scrollController.addListener(() {
      if (_scrollController.offset != 0.0 &&
          _scrollController.offset ==
              _scrollController.position.maxScrollExtent &&
          !bloc.isFetching) {
        bloc.add(WorkoutFetchEvent());
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
                BlocProvider.of<WorkoutListBloc>(context)
                    .add(SearchFilterUpdateFetchEvent(filterValue))
              },
          hintText: "Search workouts..."),
      Expanded(
        child: BlocConsumer<WorkoutListBloc, WorkoutListState>(
          listener: (ctx, state) => _onStateChange(ctx, state),
          builder: (ctx, state) => _buildList(ctx, state),
        ),
      )
    ]));
  }

  void _onStateChange(BuildContext context, WorkoutListState state) {
    if (state is WorkoutListErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.errorMessage),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Widget _buildList(BuildContext context, WorkoutListState state) {
    final bloc = BlocProvider.of<WorkoutListBloc>(context);
    if (state is WorkoutListItemModifiedState &&
        state.type == ModificationType.creation) {
      // Remember: This add works online once per build call
      WidgetsBinding.instance!.addPostFrameCallback((_) =>
          _scrollController.scrollToIndex(state.modifiedIndex,
              duration: Duration(seconds: 1),
              preferPosition: AutoScrollPosition.middle));
    } else if (state is WorkoutListErrorState && state.workouts.isEmpty) {
      return _buildReloadButton(context, bloc, state);
    }
    return _buildListView(context, bloc, state);
  }

  Widget _buildReloadButton(
      BuildContext context, WorkoutListBloc bloc, WorkoutListErrorState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => bloc.add(WorkoutFetchEvent()),
          icon: Icon(Icons.refresh),
        ),
        const SizedBox(height: 15),
        Text(state.errorMessage, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildListView(
      BuildContext context, WorkoutListBloc bloc, WorkoutListState state) {
    return SlidableAutoCloseBehavior(
        child: RefreshIndicator(
            onRefresh: () async {
              bloc.add(WorkoutFetchEvent(reload: true));
            },
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              itemBuilder: (context, index) => AutoScrollTag(
                  key: ValueKey(index),
                  controller: _scrollController,
                  index: index,
                  highlightColor: Colors.black.withOpacity(0.1),
                  child: SimpleListItem(
                    state.workouts[index].id!,
                    itemTitle: state.workouts[index].name,
                    itemSubtitle: state.workouts[index].description,
                    onClick: (id) {
                      Navigator.pushNamed(context,
                          AppRoutes.WORKOUTS_WORKOUT_DETAILS_SCREEN_ROUTE,
                          arguments: WorkoutScreenWidgetArguments(id));
                    },
                  )),
              itemCount: state.workouts.length,
            )));
  }
}
