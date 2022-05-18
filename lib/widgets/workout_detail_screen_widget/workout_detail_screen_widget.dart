import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/blocs/workout_manipulator/workout_manipulator_bloc.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/utils/known_constants.dart';
import 'package:training_app/widgets/two_letters_icon.dart';
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
        body: BlocProvider<WorkoutManipulatorBloc>(
      create: (_) =>
          WorkoutManipulatorBloc()..add(LoadWorkoutEvent(args.workoutId)),
      child: BlocBuilder<WorkoutManipulatorBloc, WorkoutManipulatorState>(
          builder: (ctx, state) => state is WorkoutManipulatorLoadedState
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

  SliverAppBar _getAppBar(BuildContext context, WorkoutManipulatorLoadedState state) {
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

  List<Widget> _buildBody(BuildContext context, WorkoutManipulatorLoadedState state,
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

  Widget _createScrollListener(Widget child, WorkoutManipulatorLoadedState state) {
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
