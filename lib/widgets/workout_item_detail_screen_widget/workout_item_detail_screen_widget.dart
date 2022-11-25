import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/utils/conversion.dart';
import 'package:training_app/utils/form_utils.dart';
import 'package:training_app/widgets/time_picker_widget.dart';
import 'package:training_app/widgets/two_letters_icon.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/bloc/workout_session_manipulator_bloc.dart';

import 'bloc/workout_item_manipulator_bloc.dart';

class WorkoutItemScreenWidgetArguments {
  final WorkoutItem workoutItem;
  final WorkoutPhase parentWorkoutPhase;
  final WorkoutSessionManipulatorBloc sessionManipulatorBloc;

  WorkoutItemScreenWidgetArguments(
      this.workoutItem, this.parentWorkoutPhase, this.sessionManipulatorBloc);
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
      child: BlocProvider<WorkoutItemManipulatorBloc>(
        create: (_) => WorkoutItemManipulatorBloc()
          ..add(LoadItemEvent(args.workoutItem, args.parentWorkoutPhase)),
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
              _buildTextFormField('Name', 'Item name', _itemNameController,
                  (value) => bloc.add(WorkoutItemNameChanged(value)),
                  validationMessage: _getNameValidationError(state)),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: _buildTextFormField(
                        'Modality',
                        'Item modality',
                        _itemModalityController,
                        (value) => bloc.add(WorkoutItemModalityChanged(value))),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildTextFormFieldNumeric(
                        'Rounds',
                        'Total number of rounds',
                        _itemRoundsController,
                        (value) => bloc.add(WorkoutItemRoundsChanged(value))),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: _buildTimeSelectionField(
                        context,
                        _itemTimeCapController,
                        state.workoutItemTimeCap.value,
                        'Timecap',
                        (value) => bloc.add(WorkoutItemTimeCapChanged(value))),
                  ),
                  Flexible(
                      child: _buildTimeSelectionField(
                          context,
                          _itemRestTimeController,
                          state.workoutItemRestTime.value,
                          'Rest',
                          (value) =>
                              bloc.add(WorkoutItemRestTimeChanged(value)))),
                  Flexible(
                      child: _buildTimeSelectionField(
                          context,
                          _itemWorkTimeController,
                          state.workoutItemWorkTime.value,
                          'Work',
                          (value) =>
                              bloc.add(WorkoutItemWorkTimeChanged(value)))),
                ],
              ),
              ..._buildSectionDivider(context, 'Sets'),
            ],
          ),
        )
      ])),
      // SliverList(
      //     delegate: SliverChildBuilderDelegate(
      //   (ctx, idx) => _buildSetWidget(ctx, state.orderedSets[idx]),
      //   childCount: state.orderedSets.length,
      // )),
      SliverReorderableList(
        itemBuilder: (ctx, idx) => ReorderableDragStartListener(
            index: idx,
            key: Key("$idx"),
            child: _buildSetWidget(ctx, state.orderedSets[idx])),
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

  Padding _buildSetWidget(BuildContext context, WorkoutSet workoutSet) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  minLeadingWidth: 20,
                  leading: TwoLettersIcon(
                    (workoutSet.sequence! + 1).toString(),
                    factor: 0.65,
                  ),
                  title: Text(workoutSet.exercise?.name ?? "<no name>"),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [..._buildSetDetails(workoutSet)],
                    ),
                  ),
                ),
              ],
            )));
  }

  SliverAppBar _buildAppBar(
      BuildContext context, final WorkoutItemManipulatorEditingState state) {
    final bloc = BlocProvider.of<WorkoutItemManipulatorBloc>(context);
    final itemName = !state.workoutItemName.dirty
        ? (state.workoutItemName.value ?? "<no name>")
        : state.workoutItemName.value ?? "";
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
                child: FlexibleSpaceBar(title: Text(itemName)),
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
      WorkoutItemManipulatorEditingState state,
      WorkoutItemManipulatorBloc bloc) {
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

  TextFormField _buildTextFormField(String label, String hint,
      TextEditingController controller, Function(String?) onChanged,
      {String? validationMessage}) {
    return TextFormField(
        controller: controller,
        keyboardType: TextInputType.name,
        onChanged: onChanged,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            hintText: hint, labelText: label, errorText: validationMessage));
  }

  TextFormField _buildTextFormFieldNumeric(String label, String hint,
      TextEditingController controller, Function(int?) onChanged) {
    return TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (value) =>
            onChanged(value.isNotEmpty ? int.tryParse(value) : null),
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(hintText: hint, labelText: label));
  }

  List<Widget> _buildSectionDivider(BuildContext context, String tittle) {
    return [
      Container(
        alignment: AlignmentDirectional.topStart,
        padding: EdgeInsets.only(top: 25),
        child: Text(
          tittle,
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
    ];
  }

  TextFormField _buildTimeSelectionField(
      BuildContext context,
      TextEditingController controller,
      int? valueSecs,
      String label,
      Function(int?) onChange) {
    return TextFormField(
      decoration: InputDecoration(
          labelText: label,
          hintText: label,
          suffixIcon: IconButton(
              icon: Icon(Icons.timer),
              onPressed: () => TimePickerWidget.showPickerDialog(
                      context, "Select ${label.toLowerCase()}",
                      initialValueSeconds: valueSecs)
                  .then((value) => onChange(value)))),

      // Note: This 2 props makes this seem disabled
      enableInteractiveSelection: false,
      controller: controller,
      // will disable paste operation
      focusNode: new AlwaysDisabledFocusNode(),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  List<Text> _buildSetDetails(WorkoutSet workoutSet) {
    final widgets = List<Text>.empty(growable: true);
    var repsSets;
    if (workoutSet.reps != null && workoutSet.setExecutions != null) {
      repsSets = "${workoutSet.reps} reps x${workoutSet.setExecutions}";
    } else if (workoutSet.reps == null) {
      repsSets = "x${workoutSet.reps} reps";
    } else if (workoutSet.setExecutions == null) {
      repsSets = "x${workoutSet.setExecutions} sets";
    }
    if (repsSets != null) {
      widgets.add(Text(
        repsSets,
        style: TextStyle(fontStyle: FontStyle.italic),
      ));
    }

    if (workoutSet.distance != null) {
      var distance;
      if (workoutSet.distance! >= 1000) {
        final kms = workoutSet.distance! / 1000;
        distance =
            "${kms.toStringAsFixed(kms.truncateToDouble() == kms ? 0 : 2)} km";
      } else {
        distance = "${workoutSet.distance} m";
      }
      widgets.add(Text(
        distance,
        style: TextStyle(fontStyle: FontStyle.italic),
      ));
    }

    if (workoutSet.weight != null) {
      widgets.add(Text(
        "${workoutSet.weight} kg",
        style: TextStyle(fontStyle: FontStyle.italic),
      ));
    }

    return widgets;
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

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
