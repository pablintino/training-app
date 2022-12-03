import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/utils/form_utils.dart';
import 'package:training_app/widgets/common/common_section_separator.dart';
import 'package:training_app/widgets/common/common_sliver_app_bar.dart';
import 'package:training_app/widgets/common/fields/common_text_form_field.dart';
import 'package:training_app/widgets/workout/bloc/workout_global_editing_bloc.dart';
import 'package:training_app/widgets/workout/workout_detail_screen_widget/bloc/workout_manipulator_bloc.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/widgets/workout/workout_list_widget/bloc/workout_list_bloc.dart';
import 'package:training_app/widgets/workout/workout_session_detail_screen_widget/workout_session_detail_screen_widget.dart';
import 'package:training_app/widgets/workout/workout_detail_screen_widget/workout_session_week_widget.dart';

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
        body: MultiBlocProvider(
      providers: [
        BlocProvider<WorkoutGlobalEditingBloc>(
          create: (_) => WorkoutGlobalEditingBloc(),
        ),
        BlocProvider<WorkoutManipulatorBloc>(
            create: (ctx) => WorkoutManipulatorBloc(args.workoutListBloc,
                BlocProvider.of<WorkoutGlobalEditingBloc>(ctx))
              ..add(LoadWorkoutEvent(args.workoutId)))
      ],
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

  Widget _buildAppBar(
      BuildContext context, final WorkoutManipulatorLoadedState state) {
    final bloc = BlocProvider.of<WorkoutManipulatorBloc>(context);
    return CommonSliverAppBar(
      options: [
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
      title: Text(state.workout.name!),
    );
  }

  List<Widget> _buildBody(BuildContext context,
      WorkoutManipulatorLoadedState state, ScrollController _scroller) {
    final bloc = BlocProvider.of<WorkoutManipulatorBloc>(context);
    return [
      _buildWorkoutFields(state, bloc),
      _buildSessionsList(context, state, bloc),

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

  SliverPadding _buildSessionsList(BuildContext context,
      WorkoutManipulatorLoadedState state, WorkoutManipulatorBloc bloc) {
    final groupedSessions = _groupSessionByWeek(state);
    return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
          (_, idx) => Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: WorkoutSessionWeekWidget(
              groupedSessions[groupedSessions.keys.elementAt(idx)]!,
              state is WorkoutManipulatorEditingState,
              groupedSessions.keys.elementAt(idx),
              onDragStatusChange: (isDragging) =>
                  bloc.add(SetSessionDraggingEvent(true)),
              onTap: (session) => Navigator.pushNamed(
                  context, AppRoutes.WORKOUTS_SESSIONS_DETAILS_SCREEN_ROUTE,
                  arguments: WorkoutSessionScreenWidgetArguments(
                      session.id!,
                      state is WorkoutManipulatorEditingState,
                      BlocProvider.of<WorkoutGlobalEditingBloc>(context))),
              onDragShouldAccept: (_, __, ___) => true,
              onDragAccept: (session, week, day) =>
                  bloc.add(DragSessionWorkoutEditionEvent(session, week, day)),
            ),
          ),
          childCount: groupedSessions.keys.length,
        )));
  }

  SliverPadding _buildWorkoutFields(
      WorkoutManipulatorLoadedState state, WorkoutManipulatorBloc bloc) {
    return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverList(
            delegate: SliverChildListDelegate([
          CommonTextFormField(
            hint: 'Name',
            enabled: state is WorkoutManipulatorEditingState,
            controller: _nameController,
            focusNode: _nameFocusNode,
            onChanged: (value) => bloc.add(NameInputUpdateEvent(value)),
            style: TextStyle(fontSize: 25.0),
            textAlign: TextAlign.left,
            validationMessage: _getNameValidationError(state),
          ),
          _buildWorkoutDescriptionField(state, bloc),
          CommonSectionSeparator(title: 'Sessions'),
        ])));
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
    return state.workout.description != null ||
            state is WorkoutManipulatorEditingState
        ? CommonTextFormField(
            hint: 'Description',
            enabled: state is WorkoutManipulatorEditingState,
            controller: _descriptionController,
            focusNode: _descriptionFocusNode,
            onChanged: (value) =>
                workoutManipulatorBloc.add(DescriptionInputUpdateEvent(value)),
            style: TextStyle(fontSize: 15.0),
            maxLines: 3,
            textAlign: TextAlign.left,
            validationMessage: _getDescriptionValidationError(state),
          )
        : Container();
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
