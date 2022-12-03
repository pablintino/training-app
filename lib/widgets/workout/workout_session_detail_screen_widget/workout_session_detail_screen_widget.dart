import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/utils/known_constants.dart';
import 'package:training_app/widgets/common/common_sliver_app_bar.dart';
import 'package:training_app/widgets/sequentiable_reorder_widget/sequentiable_reorder_widget.dart';
import 'package:training_app/widgets/workout/bloc/workout_global_editing_bloc.dart';
import 'package:training_app/widgets/workout/workout_session_detail_screen_widget/bloc/workout_session_manipulator_bloc.dart';
import 'package:training_app/widgets/workout/workout_session_detail_screen_widget/workout_phase_widget.dart';

class WorkoutSessionScreenWidgetArguments {
  final int sessionId;
  final bool initEditMode;
  final WorkoutGlobalEditingBloc workoutGlobalEditingBloc;

  WorkoutSessionScreenWidgetArguments(
      this.sessionId, this.initEditMode, this.workoutGlobalEditingBloc);
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
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: args.workoutGlobalEditingBloc),
            BlocProvider<WorkoutSessionManipulatorBloc>(
                create: (_) => WorkoutSessionManipulatorBloc(
                    args.workoutGlobalEditingBloc)
                  ..add(LoadSessionEvent(args.sessionId, args.initEditMode)))
          ],
          child: BlocBuilder<WorkoutSessionManipulatorBloc,
                  WorkoutSessionManipulatorState>(
              builder: (ctx, state) =>
                  state is WorkoutSessionManipulatorLoadedState
                      ? _buildScrollView(ctx, state)
                      : const Center(
                          child: Text('No data'),
                        )),
        ),
      ),
    );
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
      BuildContext context,
      WorkoutSessionManipulatorLoadedState state) {
    // Todo, improve
    final bloc = BlocProvider.of<WorkoutSessionManipulatorBloc>(context);
    return [
      SliverList(
          delegate: SliverChildBuilderDelegate(
        (_, idx) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: WorkoutPhaseWidget(
                state.orderedPhases[idx])),
        childCount: state.orderedPhases.length,
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

  Widget _buildAppBar(
      BuildContext context, final WorkoutSessionManipulatorLoadedState state) {
    return CommonSliverAppBar(
      options: _buildAppBarActions(context, state),
      title: Text(
          'Week ${state.workoutSession.week}, ${getDayNameFromInt(state.workoutSession.week)}'),
    );
  }

  List<Widget> _buildAppBarActions(
      BuildContext context, WorkoutSessionManipulatorLoadedState state) {
    final bloc = BlocProvider.of<WorkoutSessionManipulatorBloc>(context);
    final options = _buildEditionOptions(context, state, bloc);
    return [
      if (options.isNotEmpty)
        PopupMenuButton<Function>(
          icon: Icon(Icons.more_horiz, color: Colors.white),
          onSelected: (func) => func(),
          itemBuilder: (ctx) {
            return options;
          },
        ),
      IconButton(
        color: Colors.white,
        icon: Icon(state is WorkoutSessionManipulatorEditingState
            ? Icons.save
            : Icons.edit),
        onPressed: () => bloc.add(state is WorkoutSessionManipulatorEditingState
            ? SaveSessionWorkoutEditionEvent()
            : StartWorkoutSessionEditionEvent()),
      )
    ];
  }

  List<PopupMenuItem<Function>> _buildEditionOptions(
      BuildContext context,
      WorkoutSessionManipulatorLoadedState state,
      WorkoutSessionManipulatorBloc bloc) {
    return [
      if (state.orderedPhases.isNotEmpty &&
          state is WorkoutSessionManipulatorEditingState)
        PopupMenuItem(
          value: () {
            {
              SequentiableReorderWidget.showModal<WorkoutPhase>(
                  context,
                  state.orderedPhases,
                  (phase) => ListTile(
                        title: Text(
                          phase.name ?? '<No name>',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        trailing: Icon(Icons.drag_handle),
                      ),
                  title: const Text("Phases reorder"),
                  onReorder: (phase, index) =>
                      bloc.add(MoveWorkoutPhaseEditionEvent(phase.id!, index)));
            }
          },
          // row has two child icon and text.
          child: Row(
            children: [
              Icon(Icons.reorder),
              SizedBox(
                // sized box with width 10
                width: 10,
              ),
              Text("Reorder phases")
            ],
          ),
        ),
    ];
  }
}
