import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/widgets/workout_item_detail_screen_widget/bloc/workout_item_manipulator_bloc.dart';
import 'package:training_app/widgets/workout_set_detail_screen_widget/bloc/workout_set_manipulator_bloc.dart';

class WorkoutSetScreenWidgetArguments {
  final WorkoutSet workoutSet;
  final WorkoutItemManipulatorBloc itemManipulatorBloc;

  WorkoutSetScreenWidgetArguments(this.workoutSet, this.itemManipulatorBloc);
}

class WorkoutSetScreenWidget extends StatefulWidget {
  const WorkoutSetScreenWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WorkoutSetScreenWidgetState();
}

class _WorkoutSetScreenWidgetState extends State<WorkoutSetScreenWidget> {
  final ScrollController _scroller = ScrollController();
  final _scrollViewKey = GlobalKey();

  final _setRepetitionsController = TextEditingController();
  final _setExecutionsController = TextEditingController();
  final _setWeightController = TextEditingController();
  final _setDistanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as WorkoutSetScreenWidgetArguments;
    return Scaffold(
        body: SafeArea(
      child: BlocProvider<WorkoutSetManipulatorBloc>(
        create: (_) => WorkoutSetManipulatorBloc(args.itemManipulatorBloc)
          ..add(LoadSetEvent(args.workoutSet)),
        child:
            BlocConsumer<WorkoutSetManipulatorBloc, WorkoutSetManipulatorState>(
          builder: (ctx, state) => state is WorkoutSetManipulatorEditingState
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
        _buildAppBar(buildContext, state),
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
                    child: _buildTextFormFieldNumeric(
                        'Reps',
                        'Repetitions per set',
                        _setRepetitionsController,
                        (value) =>
                            bloc.add(WorkoutSetRepetitionsChanged(value))),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildTextFormFieldNumeric(
                        'Sets',
                        'Set repetitions',
                        _setExecutionsController,
                        (value) =>
                            bloc.add(WorkoutSetExecutionsChanged(value))),
                  ),
                ],
              ),
              _buildTextFormFieldNumeric(
                  'Weight',
                  'Weight',
                  _setWeightController,
                  (value) => bloc.add(WorkoutSetWeightChanged(value))),
              _buildTextFormFieldNumeric(
                  'Distance',
                  'Distance',
                  _setDistanceController,
                  (value) => bloc.add(WorkoutSetDistanceChanged(value)))
            ],
          ),
        )
      ])),
    ];
  }

  SliverAppBar _buildAppBar(
      BuildContext context, final WorkoutSetManipulatorEditingState state) {
    final bloc = BlocProvider.of<WorkoutSetManipulatorBloc>(context);
    final itemName =
        state.exercise != null ? "Set: ${state.exercise!.name}" : "<no name>";
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

  List<Widget> _buildAppBarActions(BuildContext context,
      WorkoutSetManipulatorEditingState state, WorkoutSetManipulatorBloc bloc) {
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

  List<PopupMenuItem<Function>> _buildEditionOptions(BuildContext context,
      WorkoutSetManipulatorEditingState state, WorkoutSetManipulatorBloc bloc) {
    return [];
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

  @override
  void dispose() {
    _setWeightController.dispose();
    _setDistanceController.dispose();
    _setExecutionsController.dispose();
    _setRepetitionsController.dispose();
    super.dispose();
  }
}
