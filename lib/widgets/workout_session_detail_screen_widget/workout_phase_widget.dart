import 'package:flutter/material.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/widgets/fixed_color_round_icon.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/workout_item_widget.dart';

class WorkoutPhaseWidget extends StatelessWidget {
  final WorkoutPhase _workoutPhase;
  final Function onPhasesReorderRequest;

  WorkoutPhaseWidget(this._workoutPhase, this.onPhasesReorderRequest);

  @override
  Widget build(BuildContext context) {
    final sortedList = List<WorkoutItem>.from(_workoutPhase.items);
    sortedList.sort((a, b) => ((a.sequence != null && b.sequence != null)
        ? (a.sequence! - b.sequence!)
        : 0));
    return Card(
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
              trailing: _buildPhaseOptions(context, sortedList),
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
                child: _buildItemList(context, sortedList),
              ),
            ),
          ],
        ));
  }

  Widget _buildItemList(BuildContext context, List<WorkoutItem> workoutItems) {
    return Column(
      children: workoutItems
          .map((workoutItem) => Padding(
                key: Key('${workoutItem.id!}'),
                padding: EdgeInsets.symmetric(vertical: 0),
                child: WorkoutItemWidget(workoutItem),
              ))
          .toList(),
    );
  }

  Widget _buildPhaseOptions(
      BuildContext context, List<WorkoutItem> workoutItems) {
    return PopupMenuButton<Function>(
      icon: Icon(Icons.more_horiz),
      onSelected: (func) => func(context, workoutItems),
      itemBuilder: (ctx) => [
        // popupmenu item 1
        PopupMenuItem(
          value: (_, __) => onPhasesReorderRequest(),
          // row has two child icon and text.
          child: Row(
            children: [
              Icon(Icons.reorder),
              SizedBox(
                // sized box with width 10
                width: 10,
              ),
              Text("Order phase")
            ],
          ),
        ),
        // popupmenu item 2
        PopupMenuItem(
          value: (_, __) {},
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
      ],
    );
  }
}
