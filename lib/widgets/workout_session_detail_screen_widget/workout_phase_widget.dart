import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/widgets/fixed_color_round_icon.dart';
import 'package:training_app/widgets/sequentiable_reorder_widget/sequentiable_reorder_widget.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/bloc/workout_session_manipulator_bloc.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/workout_item_widget.dart';

class WorkoutPhaseWidget extends StatelessWidget {
  final WorkoutPhase _workoutPhase;
  late List<WorkoutItem> _orderedPhaseItems;

  WorkoutPhaseWidget(this._workoutPhase) {
    _orderedPhaseItems = List<WorkoutItem>.from(_workoutPhase.items);
    _orderedPhaseItems.sort((a, b) =>
        ((a.sequence != null && b.sequence != null)
            ? (a.sequence! - b.sequence!)
            : 0));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<WorkoutSessionManipulatorBloc>(context);
    return BlocBuilder<WorkoutSessionManipulatorBloc,
            WorkoutSessionManipulatorState>(
        builder: (ctx, state) => Card(
            elevation: 5.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: _workoutPhase.sequence != null
                      ? FixedColorRoundIcon(_workoutPhase.sequence.toString(),
                          Colors.grey, Colors.white)
                      : null,
                  title: Text(_workoutPhase.name ?? 'No name'),
                  trailing: state is WorkoutSessionManipulatorEditingState
                      ? _buildPhaseOptions(context, bloc, state)
                      : null,
                ),
                Divider(
                  thickness: 1.0,
                  height: 1.0,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: _buildItemList(context,
                        state is WorkoutSessionManipulatorEditingState),
                  ),
                ),
              ],
            )));
  }

  Widget _buildItemList(BuildContext context, bool isEditing) {
    return Column(
      children: _orderedPhaseItems
          .map((workoutItem) => Padding(
                key: Key('${workoutItem.id!}'),
                padding: EdgeInsets.symmetric(vertical: 0),
                child: WorkoutItemWidget(workoutItem, _workoutPhase, isEditing),
              ))
          .toList(),
    );
  }

  Widget _buildPhaseOptions(
      BuildContext context,
      WorkoutSessionManipulatorBloc bloc,
      WorkoutSessionManipulatorEditingState state) {
    return PopupMenuButton<Function>(
      icon: Icon(Icons.more_horiz),
      onSelected: (func) => func(),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: () =>
              bloc.add(DeleteWorkoutPhaseEditionEvent(_workoutPhase.id!)),
          // row has two child icon and text
          child: Row(
            children: [
              Icon(Icons.delete),
              SizedBox(
                // sized box with width 10
                width: 10,
              ),
              Text("Delete")
            ],
          ),
        ),
        PopupMenuItem(
          value: () => SequentiableReorderWidget.showModal<WorkoutItem>(
              context,
              _orderedPhaseItems,
              (item) => ListTile(
                    title: Text(
                      item.name ?? '<No name>',
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    trailing: Icon(Icons.drag_handle),
                  ),
              title: const Text("Items reorder"),
              onReorder: (item, index) => bloc.add(MoveWorkoutItemEditionEvent(
                  item.id!, _workoutPhase.id!, index))),
          // row has two child icon and text
          child: Row(
            children: [
              Icon(Icons.reorder),
              SizedBox(
                // sized box with width 10
                width: 10,
              ),
              Text("Reorder items")
            ],
          ),
        ),
      ],
    );
  }
}
