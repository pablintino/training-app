import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/widgets/common/common_sliver_app_bar.dart';
import 'package:training_app/widgets/common/fields/common_numeric_form_field.dart';
import 'package:training_app/widgets/workout/bloc/workout_global_editing_bloc.dart';
import 'package:training_app/widgets/workout/workout_set_detail_screen_widget/bloc/workout_set_manipulator_bloc.dart';

class WorkoutSetScreenWidgetArguments {
  final WorkoutSet workoutSet;
  final WorkoutGlobalEditingBloc workoutGlobalEditingBloc;

  WorkoutSetScreenWidgetArguments(
      this.workoutSet, this.workoutGlobalEditingBloc);
}

class WorkoutSetScreenWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as WorkoutSetScreenWidgetArguments;
    return BlocProvider<WorkoutSetManipulatorBloc>(
        create: (_) => WorkoutSetManipulatorBloc(args.workoutGlobalEditingBloc)
          ..add(LoadSetEvent(args.workoutSet)),
        child: _WorkoutSetScreenWidget());
  }
}

class _WorkoutSetScreenWidget extends StatefulWidget {
  const _WorkoutSetScreenWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WorkoutSetScreenWidgetState();
}

class _WorkoutSetScreenWidgetState extends State<_WorkoutSetScreenWidget> {
  final ScrollController _scroller = ScrollController();
  final _scrollViewKey = GlobalKey<_WorkoutSetScreenWidgetState>();

  final _setRepetitionsController = TextEditingController();
  final _setExecutionsController = TextEditingController();
  final _setWeightController = TextEditingController();
  final _setDistanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<WorkoutSetManipulatorBloc>(context);
    return WillPopScope(
        child: Scaffold(
          body: SafeArea(
              child: BlocConsumer<WorkoutSetManipulatorBloc,
                  WorkoutSetManipulatorState>(
            bloc: bloc,
            listener: _stateChangeListener,
            builder: (ctx, state) => state is WorkoutSetManipulatorEditingState
                ? _buildScrollView(ctx, state)
                : const Center(
                    child: Text('No data'),
                  ),
          )),
        ),
        onWillPop: () async {
          return true;
        });
  }

  void _stateChangeListener(
      BuildContext context, WorkoutSetManipulatorState state) {
    if (state is WorkoutSetManipulatorErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.error),
        duration: Duration(seconds: 2),
      ));
    } else if (state is WorkoutSetManipulatorEditingState) {
      if (!state.workoutSetReps.dirty) {
        _setRepetitionsController.text =
            state.workoutSetReps.value?.toString() ?? "";
      }
      if (!state.workoutSetExecutions.dirty) {
        _setExecutionsController.text =
            state.workoutSetExecutions.value?.toString() ?? "";
      }
      if (!state.workoutSetWeight.dirty) {
        _setWeightController.text =
            state.workoutSetWeight.value?.toString() ?? "";
      }
      if (!state.workoutSetDistance.dirty) {
        _setDistanceController.text =
            state.workoutSetDistance.value?.toString() ?? "";
      }
    }
  }

  Widget _buildScrollView(
      BuildContext buildContext, WorkoutSetManipulatorEditingState state) {
    return CustomScrollView(
      key: _scrollViewKey,
      controller: _scroller,
      slivers: [
        CommonSliverAppBar(
          title: Text(state.exercise != null
              ? state.exercise!.name ?? ""
              : "<no name>"),
        ),
        ..._buildBody(buildContext, state),
      ],
    );
  }

  List<Widget> _buildBody(
      BuildContext context, WorkoutSetManipulatorEditingState state) {
    // Todo, improve
    final bloc = BlocProvider.of<WorkoutSetManipulatorBloc>(context);
    return [
      SliverList(
          delegate: SliverChildListDelegate([
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            children: [
              DropdownSearch<Exercise>(
                popupProps: PopupPropsMultiSelection.menu(
                  isFilterOnline: true,
                  showSearchBox: true,
                ),
                filterFn: (Exercise e, String filter) =>
                    e.name!.toLowerCase().contains(filter.toLowerCase()),
                items: state.availableExercises,
                dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                        hintText: "Select exercise", labelText: "Exercise")),
                itemAsString: (Exercise e) => e.name!,
                onChanged: (exercise) =>
                    bloc.add(WorkoutSetExerciseChanged(exercise)),
                selectedItem: state.exercise,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: CommonNumericFormField(
                        label: 'Reps',
                        hint: 'Repetitions per set',
                        controller: _setRepetitionsController,
                        onChanged: (value) =>
                            bloc.add(WorkoutSetRepetitionsChanged(value))),
                  ),
                  Expanded(
                    flex: 1,
                    child: CommonNumericFormField(
                        label: 'Sets',
                        hint: 'Set repetitions',
                        controller: _setExecutionsController,
                        onChanged: (value) =>
                            bloc.add(WorkoutSetExecutionsChanged(value))),
                  ),
                ],
              ),
              CommonNumericFormField(
                  label: 'Weight',
                  hint: 'Weight',
                  controller: _setWeightController,
                  onChanged: (value) =>
                      bloc.add(WorkoutSetWeightChanged(value))),
              CommonNumericFormField(
                  label: 'Distance',
                  hint: 'Distance',
                  controller: _setDistanceController,
                  onChanged: (value) =>
                      bloc.add(WorkoutSetDistanceChanged(value)))
            ],
          ),
        )
      ])),
    ];
  }

  @override
  void dispose() {
    _setWeightController.dispose();
    _setDistanceController.dispose();
    _setExecutionsController.dispose();
    _setRepetitionsController.dispose();
    super.dispose();
  }
}
