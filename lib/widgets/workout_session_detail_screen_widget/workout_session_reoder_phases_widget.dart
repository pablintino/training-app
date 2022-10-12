import 'package:flutter/material.dart';
import 'package:training_app/models/workout_models.dart';

class WorkoutSessionReorderWidget<T extends AbstractSequentiable>
    extends StatefulWidget {
  final List<T> elements;
  final ListTile Function(T) builder;
  final Function(T, int index)? onReorder;
  final Text? title;

  WorkoutSessionReorderWidget._(
      {Key? key,
      required this.elements,
      required this.builder,
      this.onReorder,
      this.title})
      : super(key: key);

  static void showPhaseReorderModal<T extends AbstractSequentiable>(
      BuildContext buildContext,
      List<T> orderedPhases,
      ListTile Function(T) builder,
      {Function(T, int index)? onReorder,
      Text? title}) async {
    await showModalBottomSheet<void>(
      context: buildContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return Wrap(children: [
          WorkoutSessionReorderWidget<T>._(
            elements: orderedPhases,
            onReorder: onReorder,
            builder: builder,
            title: title,
          )
        ]);
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _WorkoutSessionReorderWidgetState<T>();
  }
}

class _WorkoutSessionReorderWidgetState<T extends AbstractSequentiable>
    extends State<WorkoutSessionReorderWidget<T>> {
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
                  child: const Icon(Icons.arrow_back) // the arrow back icon
                  ),
            ),
            title: widget.title ??
                const Text("Drag for reorder") // Your desired title
            ),
        Container(
          height: widget.elements.length * 65 + 50,
          child: ReorderableListView.builder(
              itemBuilder: (_, index) => Card(
                    key: Key('_showReorderModal$index'),
                    elevation: 3,
                    child: widget.builder(widget.elements[index]),
                  ),
              itemCount: widget.elements.length,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final T element = widget.elements.removeAt(oldIndex);
                  widget.elements.insert(newIndex, element);
                  if (widget.onReorder != null) {
                    widget.onReorder!(widget.elements[newIndex], newIndex);
                  }
                });
              }),
        )
      ],
    );
  }
}
