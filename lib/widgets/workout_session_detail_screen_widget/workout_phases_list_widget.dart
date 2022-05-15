import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/widgets/fixed_color_round_icon.dart';

class WorkoutPhasesListWidget extends StatelessWidget {
  final List<WorkoutPhase> _workoutPhases;

  const WorkoutPhasesListWidget(this._workoutPhases, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedList = List<WorkoutPhase>.from(_workoutPhases);
    sortedList.sort((a, b) => ((a.sequence != null && b.sequence != null)
        ? (a.sequence! - b.sequence!)
        : 0));

    return ListView.builder(
      key: const PageStorageKey('workoutSessionDetailsListView'),
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (_, idx) => _PhaseContainerWidget(
        sortedList[idx],
        key: PageStorageKey('workoutSessionDetailsListViewTile$idx'),
      ),
      itemCount: _workoutPhases.length,
    );
  }
}

class _PhaseContainerWidget extends StatelessWidget {
  final WorkoutPhase _workoutPhase;

  const _PhaseContainerWidget(this._workoutPhase, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedList = List<WorkoutItem>.from(_workoutPhase.items);
    sortedList.sort((a, b) => ((a.sequence != null && b.sequence != null)
        ? (a.sequence! - b.sequence!)
        : 0));
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ExpansionTileCard(
        initialElevation: 5.0,
        elevation: 5.0,
        leading: _workoutPhase.sequence != null
            ? FixedColorRoundIcon(
                _workoutPhase.sequence.toString(), Colors.grey, Colors.white)
            : null,
        title: Text(_workoutPhase.name ?? 'No name'),
        children: <Widget>[
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
      ),
    );
  }

  Widget _buildItemList(BuildContext context, List<WorkoutItem> workoutItems) {
    return Column(
      children: workoutItems.map((e) => _buildItem(context, e)).toList(),
    );
  }

  Widget _buildItem(BuildContext context, WorkoutItem workoutItem) {
    return Padding(
      key: Key('${workoutItem.id!}'),
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Container(
              child: ListTileTheme(
                tileColor: Theme.of(context).primaryColor.withOpacity(0.3),
                child: ListTile(
                  title: Text(
                    workoutItem.name ?? 'No name',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            _buildItemDetails(context, workoutItem)
          ],
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
      itemDetails =
          itemDetails + '\nTime cap: ${workoutItem.timeCapSecs} (secs)';
    }
    if (workoutItem.workTimeSecs != null) {
      itemDetails =
          itemDetails + '\nWork time: ${workoutItem.workTimeSecs} (secs)';
    }
    if (workoutItem.restTimeSecs != null) {
      itemDetails =
          itemDetails + '\nRest time: ${workoutItem.restTimeSecs} (secs)';
    }
    if (workoutItem.workModality != null &&
        workoutItem.workModality!.isNotEmpty) {
      itemDetails = itemDetails + '\nModality: ${workoutItem.workModality}';
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
