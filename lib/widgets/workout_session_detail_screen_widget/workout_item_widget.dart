import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training_app/app_routes.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/utils/conversion.dart';
import 'package:training_app/widgets/workout_item_detail_screen_widget/workout_item_detail_screen_widget.dart';
import 'package:training_app/widgets/workout_session_detail_screen_widget/bloc/workout_session_manipulator_bloc.dart';

class WorkoutItemWidget extends StatelessWidget {
  final WorkoutItem workoutItem;
  final WorkoutPhase parentWorkoutPhase;
  final bool isEditing;

  const WorkoutItemWidget(
      this.workoutItem, this.parentWorkoutPhase, this.isEditing,
      {Key? key})
      : super(key: key);

  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          _buildItemHeader(context, workoutItem),
          _buildItemDetails(context, workoutItem)
        ],
      ),
    );
  }

  Widget _buildItemHeader(BuildContext context, WorkoutItem workoutItem) {
    return Container(
      child: ListTileTheme(
        tileColor: Theme.of(context).primaryColor.withOpacity(0.3),
        child: ListTile(
          title: Row(
            children: [
              Text(
                workoutItem.name ?? 'No name',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              if (workoutItem.workModality != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    '(${workoutItem.workModality})',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                    ),
                  ),
                ),
              Expanded(child: Container()),
              if (isEditing)
                PopupMenuButton<Function>(
                  icon: Icon(Icons.more_horiz),
                  onSelected: (func) => func(),
                  itemBuilder: (ctx) => [
                    // popupmenu item 1
                    PopupMenuItem(
                      value: () => Navigator.pushNamed(
                          context, AppRoutes.WORKOUTS_ITEM_DETAILS_SCREEN_ROUTE,
                          arguments: WorkoutItemScreenWidgetArguments(
                              workoutItem,
                              parentWorkoutPhase,
                              BlocProvider.of<WorkoutSessionManipulatorBloc>(
                                  context))),
                      // row has two child icon and text.
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(
                            // sized box with width 10
                            width: 10,
                          ),
                          Text("Edit")
                        ],
                      ),
                    ),
                    // popupmenu item 2
                    PopupMenuItem(
                      value: () {},
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildItemDetails(BuildContext context, WorkoutItem workoutItem) {
    final itemDetails = _buildWorkoutItemDetails(workoutItem);
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (itemDetails != null) itemDetails,
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: IntrinsicWidth(
              // Give the column the width of its largest child (determined by each row Wrap)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildExercisesDetailsList(context, workoutItem),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildWorkoutItemDetails(WorkoutItem workoutItem) {
    String itemDetails = '';
    if (workoutItem.rounds != null) {
      itemDetails = itemDetails + 'Rounds: ${workoutItem.rounds}';
    }
    if (workoutItem.timeCapSecs != null) {
      itemDetails = itemDetails +
          ' | T\'Cap: ${ConversionUtils.secondsTimeToPrettyString(workoutItem.timeCapSecs!)}';
    }
    if (workoutItem.workTimeSecs != null) {
      itemDetails = itemDetails +
          ' | Work: ${ConversionUtils.secondsTimeToPrettyString(workoutItem.workTimeSecs!)}';
    }
    if (workoutItem.restTimeSecs != null) {
      itemDetails = itemDetails +
          ' | Rest: ${ConversionUtils.secondsTimeToPrettyString(workoutItem.restTimeSecs!)}';
    }

    return itemDetails != ''
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(itemDetails))
        : null;
  }

  List<Widget> _buildExercisesDetailsList(
      BuildContext context, WorkoutItem workoutItem) {
    final oddBackgroundColor = Theme.of(context).primaryColor.withOpacity(0.2);
    final evenBackgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);

    List<Widget> exercisesWidgets = [];
    final sortedSets = List<WorkoutSet>.from(workoutItem.sets);
    sortedSets.sort((a, b) => ((a.sequence != null && b.sequence != null)
        ? (a.sequence! - b.sequence!)
        : 0));
    var rows = 0;
    var index = 0;
    while (index < sortedSets.length) {
      int lastEquals = _getLastEqualExerciseIndex(sortedSets, index);
      final exerciseExecutionsDetails = [
        for (var i = index; i <= lastEquals; i += 1) i
      ].map((e) => _buildSetRepsWeightTest(sortedSets[e])).toList();
      exercisesWidgets.add(_buildSetDetailsRowWidget(
          sortedSets[index],
          exerciseExecutionsDetails,
          rows % 2 == 0 ? oddBackgroundColor : evenBackgroundColor));

      //Update index
      if (lastEquals + 1 == index) {
        break;
      }
      index = lastEquals + 1;
      rows++;
    }
    return exercisesWidgets;
  }

  Container _buildSetDetailsRowWidget(WorkoutSet workoutSet,
      List<Text> exerciseExecutionsDetails, Color backgroundColor) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: IntrinsicHeight(
            child: Wrap(
          children: [
            Text(
              workoutSet.exercise?.name ?? 'Unknown exercise',
              textAlign: TextAlign.start,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exerciseExecutionsDetails),
            ),
          ],
        )),
      ),
    );
  }

  int _getLastEqualExerciseIndex(
      final List<WorkoutSet> workoutSets, final int startIndex) {
    int lastIndex = startIndex;
    while (lastIndex < workoutSets.length) {
      if (lastIndex + 1 < workoutSets.length &&
          workoutSets[lastIndex].exerciseId ==
              workoutSets[lastIndex + 1].exerciseId) {
        lastIndex = lastIndex + 1;
      } else {
        break;
      }
    }
    return lastIndex;
  }

  Text _buildSetRepsWeightTest(WorkoutSet workoutSet) {
    final String weight =
        workoutSet.weight != null ? '${workoutSet.weight} Kg' : '';
    final String distance =
        workoutSet.distance != null ? '${workoutSet.distance} m' : '';
    String reps = '';
    if (workoutSet.setExecutions != null && workoutSet.reps != null) {
      reps = '${workoutSet.reps}x ${workoutSet.setExecutions}';
    } else if (workoutSet.setExecutions != null || workoutSet.reps != null) {
      reps = 'x${workoutSet.setExecutions ?? workoutSet.reps}';
    }

    return Text('$reps $weight $distance');
  }
}
