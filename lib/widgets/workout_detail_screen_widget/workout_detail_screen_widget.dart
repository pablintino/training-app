import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/utils/form_utils.dart';
import 'package:training_app/widgets/workout_detail_screen_widget/bloc/workout_manipulator_bloc.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/widgets/workout_list_widget/bloc/workout_list_bloc.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/workout_session_detail_screen_widget.dart';
import 'package:training_app/widgets/workout_detail_screen_widget/workout_session_week_widget.dart';

class WorkoutScreenWidgetArguments {
  final int workoutId;
  final WorkoutListBloc workoutListBloc;

  WorkoutScreenWidgetArguments(this.workoutId, this.workoutListBloc);
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

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
      create: (_) => WorkoutManipulatorBloc(args.workoutListBloc)
        ..add(LoadWorkoutEvent(args.workoutId)),
      child: BlocConsumer<WorkoutManipulatorBloc, WorkoutManipulatorState>(
          listener: _stateChangeListener,
          builder: (ctx, state) => state is WorkoutManipulatorLoadedState
              ? _buildScrollView(ctx, state)
              : const Center(
                  child: Text('No data'),
                )),
    ));
  }

  void _stateChangeListener(
      BuildContext context, WorkoutManipulatorState state) {
    if (state is WorkoutManipulatorErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.error),
        duration: Duration(seconds: 2),
      ));
    } else if (state is WorkoutManipulatorEditingState) {
      if (!state.workoutName.dirty) {
        _nameController.text = state.workoutName.value ?? '';
      }
      if (!state.workoutDescription.dirty) {
        _descriptionController.text = state.workoutDescription.value ?? '';
      }
    } else if (state is WorkoutManipulatorLoadedState) {
      _descriptionController.text = state.workout.description ?? '';
      _nameController.text = state.workout.name ?? '';
    }
  }

  SliverAppBar _buildAppBar(
      BuildContext context, WorkoutManipulatorLoadedState state) {
    final bloc = BlocProvider.of<WorkoutManipulatorBloc>(context);
    return SliverAppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Theme.of(context).primaryColor,
      expandedHeight: 125,
      floating: true,
      pinned: true,
      //flexibleSpace: FlexibleSpaceBar(
      //  background: Image.network(
      //    'https://source.unsplash.com/random?monochromatic+dark',
      //    fit: BoxFit.cover,
      //  ),
      //  title: Text(state.workout.name!),
      flexibleSpace: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            width: 300,
            child: FlexibleSpaceBar(title: Text(state.workout.name!)),
          ),
          Spacer(),
          IconButton(
            color: Colors.white,
            icon: Icon(state is WorkoutManipulatorEditingState
                ? Icons.save
                : Icons.edit),
            onPressed: () => bloc.add(state is WorkoutManipulatorEditingState
                ? SaveWorkoutEditionEvent()
                : StartWorkoutEditionEvent()),
          )
        ],
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context,
      WorkoutManipulatorLoadedState state, ScrollController _scroller) {
    final groupedSessions = _groupSessionByWeek(state);
    final bloc = BlocProvider.of<WorkoutManipulatorBloc>(context);
    return [
      SliverList(
          delegate: SliverChildListDelegate([
        _buildWorkoutNameField(state, bloc),
        _buildWorkoutDescriptionField(state, bloc),
        _buildSessionsSeparator(context),
      ])),
      SliverList(
          delegate: SliverChildBuilderDelegate(
        (_, idx) => WorkoutSessionWeekWidget(
          groupedSessions[groupedSessions.keys.elementAt(idx)]!,
          state is WorkoutManipulatorEditingState,
          groupedSessions.keys.elementAt(idx),
          onDragStatusChange: (isDragging) =>
              bloc.add(SetSessionDraggingEvent(true)),
          onTap: (session) => Navigator.pushNamed(
              context, AppRoutes.WORKOUTS_SESSIONS_DETAILS_SCREEN_ROUTE,
              arguments: WorkoutSessionScreenWidgetArguments(session.id!)),
          onDragShouldAccept: (_, __, ___) => true,
          onDragAccept: (session, week, day) =>
              bloc.add(DragSessionWorkoutEditionEvent(session, week, day)),
        ),
        childCount: groupedSessions.keys.length,
      )),

      // This SizedBox helps drag&drop at the bottom of the screen
      if (state is WorkoutManipulatorEditingState)
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

  Map<int, List<WorkoutSession>> _groupSessionByWeek(
      WorkoutManipulatorLoadedState state) {
    Map<int, List<WorkoutSession>> groupedSessions = {};
    for (WorkoutSession workoutSession in state.workout.sessions) {
      final sessionToAdd = state is WorkoutManipulatorEditingState &&
              state.movedSessions.containsKey(workoutSession.id)
          ? state.movedSessions[workoutSession.id]!
          : workoutSession;

      if (!groupedSessions.containsKey(sessionToAdd.week)) {
        // TODO Review !
        groupedSessions[sessionToAdd.week!] = [];
      }
      groupedSessions[sessionToAdd.week!]!.add(sessionToAdd);
    }

    // Sort by day
    groupedSessions.forEach(
        (_, sessions) => sessions.sort((a, b) => a.weekDay! - b.weekDay!));

    return groupedSessions;
  }

  Widget _buildWorkoutDescriptionField(WorkoutManipulatorLoadedState state,
      WorkoutManipulatorBloc workoutManipulatorBloc) {
    final isEditing = state is WorkoutManipulatorEditingState;
    return state.workout.description != null ||
            state is WorkoutManipulatorEditingState
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: TextFormField(
              enabled: state is WorkoutManipulatorEditingState,
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              onChanged: (value) => workoutManipulatorBloc
                  .add(DescriptionInputUpdateEvent(value)),
              decoration: !isEditing
                  ? InputDecoration(
                      border: InputBorder.none,
                      hintText: state.workout.name!,
                      errorText: _getDescriptionValidationError(state))
                  : InputDecoration(
                      errorText: _getDescriptionValidationError(state)),
              style: TextStyle(fontSize: 15.0),
              maxLines: 3,
              textAlign: TextAlign.left,
            ),
          )
        : Container();
  }

  Widget _buildSessionsSeparator(BuildContext context) {
    return PreferredSize(
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
    );
  }

  Padding _buildWorkoutNameField(WorkoutManipulatorLoadedState state,
      WorkoutManipulatorBloc workoutManipulatorBloc) {
    final isEditing = state is WorkoutManipulatorEditingState;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: TextFormField(
        enabled: isEditing,
        controller: _nameController,
        focusNode: _nameFocusNode,
        onChanged: (value) =>
            workoutManipulatorBloc.add(NameInputUpdateEvent(value)),
        decoration: !isEditing
            ? InputDecoration(
                border: InputBorder.none,
                hintText: state.workout.name!,
                errorText: _getNameValidationError(state))
            : InputDecoration(errorText: _getNameValidationError(state)),
        style: TextStyle(fontSize: 25.0),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildScrollView(
      BuildContext buildContext, WorkoutManipulatorLoadedState state) {
    final scrollView = CustomScrollView(
      key: _scrollViewKey,
      controller: _scroller,
      slivers: [
        _buildAppBar(buildContext, state),
        ..._buildBody(buildContext, state, _scroller),
      ],
    );
    return state is WorkoutManipulatorEditingState
        ? Listener(
            child: scrollView,
            onPointerMove: (PointerMoveEvent event) {
              if (!state.isDragging) {
                return;
              }

              RenderBox render = _scrollViewKey.currentContext
                  ?.findRenderObject() as RenderBox;
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
          )
        : scrollView;
  }

  String? _getNameValidationError(WorkoutManipulatorState state) {
    ValidationError? validationError =
        state is WorkoutManipulatorEditingState && state.workoutName.dirty
            ? state.workoutName.status
            : null;
    return validationError == null
        ? null
        : (validationError == ValidationError.empty
            ? 'Workout name cannot be empty'
            : 'Workout name already exists');
  }

  String? _getDescriptionValidationError(WorkoutManipulatorState state) {
    ValidationError? validationError =
        state is WorkoutManipulatorEditingState &&
                state.workoutDescription.dirty
            ? state.workoutDescription.status
            : null;
    return validationError != null && validationError == ValidationError.empty
        ? 'Workout description cannot be empty'
        : null;
  }
}
