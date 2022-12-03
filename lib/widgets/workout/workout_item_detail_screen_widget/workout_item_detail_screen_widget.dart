import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/utils/conversion.dart';
import 'package:training_app/utils/form_utils.dart';
import 'package:training_app/widgets/common/common_section_separator.dart';
import 'package:training_app/widgets/common/common_sliver_app_bar.dart';
import 'package:training_app/widgets/common/fields/common_numeric_form_field.dart';
import 'package:training_app/widgets/common/fields/common_text_form_field.dart';
import 'package:training_app/widgets/common/fields/common_time_picker_form_field.dart';
import 'package:training_app/widgets/workout/bloc/workout_global_editing_bloc.dart';
import 'package:training_app/widgets/workout/workout_item_detail_screen_widget/workout_item_detail_set_widget.dart';
import 'package:training_app/widgets/workout/workout_set_detail_screen_widget/workout_set_detail_screen_widget.dart';

import 'bloc/workout_item_manipulator_bloc.dart';

class WorkoutItemScreenWidgetArguments {
  final WorkoutItem workoutItem;
  final WorkoutPhase parentWorkoutPhase;
  final WorkoutGlobalEditingBloc workoutGlobalEditingBloc;

  WorkoutItemScreenWidgetArguments(
      this.workoutItem, this.parentWorkoutPhase, this.workoutGlobalEditingBloc);
}

class WorkoutItemScreenWidget extends StatefulWidget {
  const WorkoutItemScreenWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WorkoutItemScreenWidgetState();
}

class _WorkoutItemScreenWidgetState extends State<WorkoutItemScreenWidget> {
  final ScrollController _scroller = ScrollController();
  final _scrollViewKey = GlobalKey();

  final _itemWorkTimeController = TextEditingController();
  final _itemRestTimeController = TextEditingController();
  final _itemTimeCapController = TextEditingController();
  final _itemRoundsController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemModalityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as WorkoutItemScreenWidgetArguments;
    return Scaffold(
        body: SafeArea(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<WorkoutGlobalEditingBloc>.value(
              value: args.workoutGlobalEditingBloc),
          BlocProvider<WorkoutItemManipulatorBloc>(
              create: (_) => WorkoutItemManipulatorBloc(
                  args.workoutGlobalEditingBloc)
                ..add(LoadItemEvent(args.workoutItem, args.parentWorkoutPhase)))
        ],
        child: BlocConsumer<WorkoutItemManipulatorBloc,
            WorkoutItemManipulatorState>(
          builder: (ctx, state) => state is WorkoutItemManipulatorEditingState
              ? _buildScrollView(ctx, state)
              : const Center(
                  child: Text('No data'),
                ),
          listener: _stateChangeListener,
        ),
      ),
    ));
  }

  void _stateChangeListener(
      BuildContext context, WorkoutItemManipulatorState state) {
    if (state is WorkoutItemManipulatorErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.error),
        duration: Duration(seconds: 2),
      ));
    } else if (state is WorkoutItemManipulatorEditingState) {
      _itemRestTimeController.text = state.workoutItemRestTime.value != null
          ? ConversionUtils.secondsTimeToPrettyString(
              state.workoutItemRestTime.value!)
          : "";

      _itemWorkTimeController.text = state.workoutItemWorkTime.value != null
          ? ConversionUtils.secondsTimeToPrettyString(
              state.workoutItemWorkTime.value!)
          : "";

      _itemTimeCapController.text = state.workoutItemTimeCap.value != null
          ? ConversionUtils.secondsTimeToPrettyString(
              state.workoutItemTimeCap.value!)
          : "";
      if (!state.workoutItemRounds.dirty) {
        _itemRoundsController.text = state.workoutItemRounds.value != null
            ? state.workoutItemRounds.value.toString()
            : "";
      }

      if (!state.workoutItemName.dirty) {
        _itemNameController.text = state.workoutItemName.value ?? "";
      }
      if (!state.workoutItemModality.dirty) {
        _itemModalityController.text = state.workoutItemModality.value ?? "";
      }
    }
  }

  Widget _buildScrollView(
      BuildContext buildContext, WorkoutItemManipulatorEditingState state) {
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
      BuildContext context, WorkoutItemManipulatorEditingState state) {
    // Todo, improve
    final bloc = BlocProvider.of<WorkoutItemManipulatorBloc>(context);
    return [
      SliverList(
          delegate: SliverChildListDelegate([
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            children: [
              CommonTextFormField(
                  label: 'Name',
                  hint: 'Item name',
                  controller: _itemNameController,
                  onChanged: (value) => bloc.add(WorkoutItemNameChanged(value)),
                  validationMessage: _getNameValidationError(state)),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: CommonTextFormField(
                        label: 'Modality',
                        hint: 'Item modality',
                        controller: _itemModalityController,
                        onChanged: (value) =>
                            bloc.add(WorkoutItemModalityChanged(value))),
                  ),
                  Expanded(
                    flex: 1,
                    child: CommonNumericFormField(
                        controller: _itemRoundsController,
                        label: 'Rounds',
                        hint: 'Total number of rounds',
                        onChanged: (value) => bloc.add(
                              WorkoutItemRoundsChanged(value),
                            )),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: CommonTimePickerFormField(
                        controller: _itemTimeCapController,
                        valueSecs: state.workoutItemTimeCap.value,
                        label: 'Timecap',
                        onChange: (value) =>
                            bloc.add(WorkoutItemTimeCapChanged(value))),
                  ),
                  Flexible(
                      child: CommonTimePickerFormField(
                          controller: _itemRestTimeController,
                          valueSecs: state.workoutItemRestTime.value,
                          label: 'Rest',
                          onChange: (value) =>
                              bloc.add(WorkoutItemRestTimeChanged(value)))),
                  Flexible(
                      child: CommonTimePickerFormField(
                          controller: _itemWorkTimeController,
                          valueSecs: state.workoutItemWorkTime.value,
                          label: 'Work',
                          onChange: (value) =>
                              bloc.add(WorkoutItemWorkTimeChanged(value)))),
                ],
              ),
              CommonSectionSeparator(title: 'Sets'),
            ],
          ),
        )
      ])),
      SliverReorderableList(
        itemBuilder: (ctx, idx) => ReorderableDragStartListener(
            index: idx,
            key: Key("$idx"),
            child: WorkoutItemDetailSetWidget(
              workoutSet: state.orderedSets[idx],
              onTap: (workoutSet) => Navigator.pushNamed(
                  context, AppRoutes.WORKOUTS_SET_DETAILS_SCREEN_ROUTE,
                  arguments: WorkoutSetScreenWidgetArguments(workoutSet,
                      BlocProvider.of<WorkoutGlobalEditingBloc>(context))),
            )),
        onReorder: (int oldIndex, int newIndex) => bloc.add(
            MoveWorkoutSetEditionEvent(state.orderedSets[oldIndex],
                oldIndex < newIndex ? newIndex - 1 : newIndex)),
        itemCount: state.orderedSets.length,
      ),
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
      BuildContext context, final WorkoutItemManipulatorEditingState state) {
    final itemName = !state.workoutItemName.dirty
        ? (state.workoutItemName.value ?? "<no name>")
        : state.workoutItemName.value ?? "";
    return CommonSliverAppBar(
      options: _buildAppBarActions(context, state),
      title: Text(itemName),
    );
  }

  List<Widget> _buildAppBarActions(
      BuildContext context, WorkoutItemManipulatorEditingState state) {
    final bloc = BlocProvider.of<WorkoutItemManipulatorBloc>(context);
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
        icon: Icon(Icons.save),
        onPressed: () {},
      )
    ];
  }

  List<PopupMenuItem<Function>> _buildEditionOptions(
      BuildContext context,
      WorkoutItemManipulatorEditingState state,
      WorkoutItemManipulatorBloc bloc) {
    return [
      if (state.orderedSets.isNotEmpty)
        PopupMenuItem(
          value: () {},
          // row has two child icon and text.
          child: Row(
            children: [
              Icon(Icons.reorder),
              SizedBox(
                // sized box with width 10
                width: 10,
              ),
              Text("Reorder sets")
            ],
          ),
        ),
    ];
  }

  String? _getNameValidationError(WorkoutItemManipulatorEditingState state) {
    ValidationError? validationError =
        state.workoutItemName.dirty ? state.workoutItemName.status : null;
    return validationError == null
        ? null
        : (validationError == ValidationError.empty
            ? 'Item name cannot be empty'
            : 'Item name already exists');
  }

  @override
  void dispose() {
    _itemTimeCapController.dispose();
    _itemWorkTimeController.dispose();
    _itemRestTimeController.dispose();
    _itemRoundsController.dispose();
    _itemNameController.dispose();
    _itemModalityController.dispose();
    super.dispose();
  }
}
