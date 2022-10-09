import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/utils/known_constants.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/bloc/workout_session_manipulator_bloc.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/workout_phase_widget.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/workout_session_reoder_phases_widget.dart';

class WorkoutSessionScreenWidgetArguments {
  final int sessionId;
  final bool initEditMode;

  WorkoutSessionScreenWidgetArguments(this.sessionId, this.initEditMode);
}

class WorkoutSessionScreenWidget extends StatefulWidget {
  const WorkoutSessionScreenWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WorkoutSessionScreenWidgetState();
}

class _WorkoutSessionScreenWidgetState
    extends State<WorkoutSessionScreenWidget> {
  final ScrollController _scroller = ScrollController();
  final _scrollViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as WorkoutSessionScreenWidgetArguments;
    return Scaffold(
        body: SafeArea(
      child: BlocProvider<WorkoutSessionManipulatorBloc>(
        create: (_) => WorkoutSessionManipulatorBloc()
          ..add(LoadSessionEvent(args.sessionId, args.initEditMode)),
        child: BlocBuilder<WorkoutSessionManipulatorBloc,
                WorkoutSessionManipulatorState>(
            builder: (ctx, state) =>
                state is WorkoutSessionManipulatorLoadedState
                    ? _buildScrollView(ctx, state)
                    : const Center(
                        child: Text('No data'),
                      )),
      ),
    ));
  }

  Widget _buildScrollView(
      BuildContext buildContext, WorkoutSessionManipulatorLoadedState state) {
    return CustomScrollView(
      key: _scrollViewKey,
      controller: _scroller,
      slivers: [
        _buildAppBar(buildContext, state),
        ..._buildBody(buildContext, state),
      ],
    );
  }

  List<Widget> _buildBody(
      BuildContext context, WorkoutSessionManipulatorLoadedState state) {
    // Todo, improve
    final ordererdPhases =
        List<WorkoutPhase>.from(state.workoutSession.phases, growable: true);
    if (state is WorkoutSessionManipulatorEditingState) {
      for (final movedKv in state.movedPhases.entries) {
        final index =
            ordererdPhases.indexWhere((element) => element.id == movedKv.key);
        if (index >= 0) {
          ordererdPhases.removeAt(index);
          ordererdPhases.add(movedKv.value);
        }
      }
    }
    ordererdPhases.sort((a, b) => a.sequence!.compareTo(b.sequence!));

    final bloc = BlocProvider.of<WorkoutSessionManipulatorBloc>(context);
    return [
      SliverList(
          delegate: SliverChildBuilderDelegate(
        (_, idx) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: WorkoutPhaseWidget(ordererdPhases[idx], () {
              WorkoutSessionReorderPhasesWidget.showPhaseReorderModal(
                  context, ordererdPhases,
                  onReorder: (phase) => bloc.add(
                      MoveWorkoutPhaseEditionEvent(phase, phase.sequence!)));
            })),
        childCount: ordererdPhases.length,
      )),

      // This SizedBox helps drag&drop at the bottom of the screen
      if (state is WorkoutSessionManipulatorEditingState)
        SliverToBoxAdapter(
          child: Container(
            height: 100,
            child: Center(
              child: RawMaterialButton(
                onPressed: () {},
                elevation: 2.0,
                fillColor: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(15.0),
                shape: CircleBorder(),
              ),
            ),
          ),
        )
    ];
  }

  SliverAppBar _buildAppBar(
      BuildContext context, WorkoutSessionManipulatorLoadedState state) {
    final bloc = BlocProvider.of<WorkoutSessionManipulatorBloc>(context);
    return SliverAppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Theme.of(context).primaryColor,
      expandedHeight: 125,
      floating: true,
      pinned: true,
      flexibleSpace: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.network(
              'https://source.unsplash.com/random?monochromatic+dark',
              fit: BoxFit.cover,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 300,
                child: FlexibleSpaceBar(
                    title: Text(
                        'Week ${state.workoutSession.week}, ${getDayNameFromInt(state.workoutSession.week)}')),
              ),
              Expanded(child: Container()),
              IconButton(
                color: Colors.white,
                icon: Icon(state is WorkoutSessionManipulatorEditingState
                    ? Icons.save
                    : Icons.edit),
                onPressed: () => bloc.add(
                    state is WorkoutSessionManipulatorEditingState
                        ? SaveSessionWorkoutEditionEvent()
                        : StartWorkoutSessionEditionEvent()),
              )
            ],
          )
        ],
      ),
    );
  }
}
