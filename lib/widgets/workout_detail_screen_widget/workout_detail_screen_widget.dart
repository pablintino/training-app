import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/utils/known_constants.dart';
import 'package:training_app/widgets/two_letters_icon.dart';
import 'package:training_app/widgets/workout_detail_screen_widget/bloc/workout_details_bloc.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/workout_session_detail_screen_widget.dart';

class WorkoutScreenWidgetArguments {
  final int workoutId;

  WorkoutScreenWidgetArguments(this.workoutId);
}

class WorkoutDetailsScreenWidget extends StatefulWidget {
  const WorkoutDetailsScreenWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WorkoutDetailsScreenWidgetState();
}

class _WorkoutDetailsScreenWidgetState
    extends State<WorkoutDetailsScreenWidget> {
  final ScrollController _scroller = ScrollController();
  final _scrollViewKey = GlobalKey();

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as WorkoutScreenWidgetArguments;
    return Scaffold(
        body: BlocProvider<WorkoutDetailsBloc>(
      create: (_) =>
          WorkoutDetailsBloc()..add(LoadWorkoutEvent(args.workoutId)),
      child: BlocBuilder<WorkoutDetailsBloc, WorkoutDetailsState>(
          builder: (ctx, state) => state is WorkoutLoadedState
              ? _createScrollListener(
                  CustomScrollView(
                    key: _scrollViewKey,
                    controller: _scroller,
                    slivers: [
                      _getAppBar(ctx, state),
                      ..._buildBody(ctx, state, _scroller),
                    ],
                  ),
                  state)
              : const Center(
                  child: Text('No data'),
                )),
    ));
  }

  SliverAppBar _getAppBar(BuildContext context, WorkoutLoadedState state) {
    return SliverAppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Theme.of(context).primaryColor,
      expandedHeight: 150,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          'https://source.unsplash.com/random?monochromatic+dark',
          fit: BoxFit.cover,
        ),
        title: Text(state.workout.name!),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context, WorkoutLoadedState state,
      ScrollController _scroller) {
    Map<int, List<WorkoutSession>> groupedSessions = {};
    for (WorkoutSession workoutSession in state.workout.sessions) {
      if (!groupedSessions.containsKey(workoutSession.week)) {
        // TODO Review !
        groupedSessions[workoutSession.week!] = [];
      }
      groupedSessions[workoutSession.week!]!.add(workoutSession);
    }

    return [
      SliverList(
          delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: state.workout.name!,
            ),
            initialValue: state.workout.name!,
            style: TextStyle(fontSize: 25.0),
            textAlign: TextAlign.left,
          ),
        ),
        state.workout.description != null
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: TextFormField(
                  enabled: false,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: state.workout.description,
                  ),
                  initialValue: state.workout.description,
                  style: TextStyle(fontSize: 15.0),
                  maxLines: 3,
                  textAlign: TextAlign.left,
                ),
              )
            : Container(), // TODO Review a better way
        PreferredSize(
          preferredSize:
              Size(double.infinity, MediaQuery.of(context).size.height / 6),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  alignment: AlignmentDirectional.topStart,
                  child: Text(
                    'Sessions',
                    style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.left,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 50,
                      child: Divider(
                        thickness: 1,
                        color: Colors.blue.withOpacity(0.5),
                      ),
                    ),
                    Expanded(child: Container())
                  ],
                )
              ],
            ),
          ),
        ),
      ])),
      SliverList(
          delegate: SliverChildBuilderDelegate(
        (_, idx) => _WeekSessionsCardWidget(
            groupedSessions[groupedSessions.keys.elementAt(idx)]!, _scroller),
        childCount: groupedSessions.keys.length,
      )),
      if (state.isDragging)
        SliverToBoxAdapter(
          child: SizedBox(child: Container(), height: 100),
        )
    ];
  }

  Widget _createScrollListener(Widget child, WorkoutLoadedState state) {
    return Listener(
      child: child,
      onPointerMove: (PointerMoveEvent event) {
        if (!state.isDragging) {
          return;
        }

        RenderBox render =
            _scrollViewKey.currentContext?.findRenderObject() as RenderBox;
        Offset position = render.localToGlobal(Offset.zero);

        const detectedRange = 100;
        const moveDistance = 3;
        if (event.position.dy < position.dy + detectedRange) {
          var to = _scroller.offset - moveDistance;
          to = (to < 0) ? 0 : to;
          _scroller.jumpTo(to);
        }
        if (event.position.dy >
            position.dy + render.size.height - detectedRange) {
          _scroller.jumpTo(_scroller.offset + moveDistance);
        }
      },
    );
  }
}

class _WeekSessionsCardWidget extends StatefulWidget {
  final List<WorkoutSession> weekSessions;
  final ScrollController scroller;

  const _WeekSessionsCardWidget(this.weekSessions, this.scroller, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeekSessionsCardWidgetState();
}

class _WeekSessionsCardWidgetState extends State<_WeekSessionsCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: ExpansionTileCard(
        initialElevation: 5.0,
        elevation: 5.0,
        title: Text('Week ${widget.weekSessions.elementAt(0).week}'),
        children: <Widget>[
          Divider(
            thickness: 1.0,
            height: 1.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 5.0,
            ),
            child: _buildList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext buildContext) {
    final week = widget.weekSessions.elementAt(0).week!;
    return ScrollConfiguration(
        behavior: _ClampingScrollBehavior(),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            if (index % 2 == 0) {
              return _buildDragTargets(context, index, week);
            } else {
              return _buildDraggableSessionItem(buildContext,
                  widget.weekSessions.elementAt((index - 1) ~/ 2));
            }
          },
          itemCount: widget.weekSessions.length * 2 + 1,
        ));
  }

  Widget _buildDragTargets(BuildContext context, int index, int week) {
    return DragTarget<WorkoutSession>(
//      builder responsible to build a widget based on whether there is an item being dropped or not
      builder: (context, candidates, rejects) {
        return candidates.length > 0
            ? _buildDraggableSessionItem(context, candidates[0]!)
            : Container(
                width: 5,
                height: 5,
              );
      },
//      condition on to accept the item or not
      //onWillAccept: (value)=>!listA.contains(value),
      onWillAccept: (value) => true,
//      what to do when an item is accepted
      onAccept: (value) {
        print('test');
        // setState(() {
        //  listA.insert(index + 1, value);
        //  listB.remove(value);
        //  });
      },
    );
  }

  Widget _buildDraggableSessionItem(
      BuildContext buildContext, WorkoutSession session) {
    final sessionDay = getDayNameFromInt(session.weekDay);
    final bloc = BlocProvider.of<WorkoutDetailsBloc>(context);
    // LayoutBuilder needed to pass width to child
    return LayoutBuilder(
      builder: (context, constraints) => LongPressDraggable<WorkoutSession>(
        data: session,
        onDragStarted: () => bloc.add(UpdateDraggingStateEvent(true)),
        onDragEnd: (details) => bloc.add(UpdateDraggingStateEvent(false)),
        onDraggableCanceled: (velocity, offset) =>
            bloc.add(UpdateDraggingStateEvent(false)),
        feedback: Container(
          width: constraints.maxWidth,
          child: _buildSessionCard(sessionDay, session),
        ),
        childWhenDragging: Card(
          elevation: 2,
          color: Colors.grey.shade50,
          child: ListTile(),
        ),
        child: _buildSessionCard(sessionDay, session),
      ),
    );
  }

  Card _buildSessionCard(String sessionDay, WorkoutSession session) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: TwoLettersIcon(
          sessionDay,
          factor: 0.7,
        ),
        title: Text(
          sessionDay,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
              context, AppRoutes.WORKOUTS_SESSIONS_DETAILS_SCREEN_ROUTE,
              arguments: WorkoutSessionScreenWidgetArguments(session.id!));
        },
      ),
    );
  }
}

class _ClampingScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      ClampingScrollPhysics();
}
