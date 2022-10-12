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
    final bloc = BlocProvider.of<WorkoutSessionManipulatorBloc>(context);
    return [
      SliverList(
          delegate: SliverChildBuilderDelegate(
        (_, idx) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: WorkoutPhaseWidget(state.orderedPhases[idx])),
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

  SliverAppBar _buildAppBar(
      BuildContext context, final WorkoutSessionManipulatorLoadedState state) {
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
                width: MediaQuery.of(context).size.width * 3 / 4,
                child: FlexibleSpaceBar(
                    title: Text(
                        'Week ${state.workoutSession.week}, ${getDayNameFromInt(state.workoutSession.week)}')),
              ),
              Expanded(child: Container()),
              ..._buildAppBarActions(context, state, bloc)
            ],
          )
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions(
      BuildContext context,
      WorkoutSessionManipulatorLoadedState state,
      WorkoutSessionManipulatorBloc bloc) {
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
      if (state.orderedPhases.isNotEmpty)
        PopupMenuItem(
          value: () {
            {
              WorkoutSessionReorderWidget.showPhaseReorderModal<WorkoutPhase>(
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
                      bloc.add(MoveWorkoutPhaseEditionEvent(phase, index)));
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
