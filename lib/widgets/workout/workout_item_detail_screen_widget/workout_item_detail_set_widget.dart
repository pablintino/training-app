import 'package:flutter/material.dart';
import 'package:training_app/models/workout_models.dart';
import 'package:training_app/widgets/two_letters_icon.dart';

class WorkoutItemDetailSetWidget extends StatelessWidget {
  final WorkoutSet workoutSet;
  final Function(WorkoutSet) onTap;

  const WorkoutItemDetailSetWidget(
      {Key? key, required this.workoutSet, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: GestureDetector(
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
              )),
          onTap: () => onTap(workoutSet),
        ));
  }

  static List<Text> _buildSetDetails(WorkoutSet workoutSet) {
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
}
