import 'package:flutter/material.dart';
import 'package:training_app/models/workout_models.dart';

typedef ReorderCallable = void Function(WorkoutPhase phase);

class WorkoutSessionReorderPhasesWidget extends StatefulWidget {
  final List<WorkoutPhase> phases;
  final ReorderCallable? onReorder;

  WorkoutSessionReorderPhasesWidget._(
      {Key? key, required this.phases, this.onReorder})
      : super(key: key) {
    phases.sort((a, b) => ((a.sequence != null && b.sequence != null)
        ? (a.sequence! - b.sequence!)
        : 0));
  }

  static void showPhaseReorderModal(
      BuildContext buildContext, List<WorkoutPhase> orderedPhases,
      {ReorderCallable? onReorder}) async {
    await showModalBottomSheet<void>(
      context: buildContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return Wrap(children: [
          WorkoutSessionReorderPhasesWidget._(
            phases: orderedPhases,
            onReorder: onReorder,
          )
        ]);
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _WorkoutSessionReorderPhasesWidgetState(phases);
  }
}

class _WorkoutSessionReorderPhasesWidgetState
    extends State<WorkoutSessionReorderPhasesWidget> {
  final List<WorkoutPhase> _phases;

  _WorkoutSessionReorderPhasesWidgetState(this._phases);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
            leading: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.arrow_back) // the arrow back icon
                  ),
            ),
            title: Text("Phases reorder") // Your desired title
            ),
        Container(
          height: _phases.length * 65 + 50,
          child: ReorderableListView.builder(
              itemBuilder: (_, index) => Card(
                    key: Key('_showReorderModal$index'),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        _phases[index].name ?? '<No name>',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      trailing: Icon(Icons.drag_handle),
                    ),
                  ),
              itemCount: _phases.length,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final WorkoutPhase phase = _phases.removeAt(oldIndex);
                  _phases.insert(newIndex, phase);
                  for (int index = 0; index < _phases.length; index += 1) {
                    _phases[index] = _phases[index].copyWith(sequence: index);
                  }

                  if (widget.onReorder != null) {
                    widget.onReorder!(_phases[newIndex]);
                  }
                });
              }),
        )
      ],
    );
  }
}
