import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/widgets/two_letters_icon/two_letters_icon.dart';

class ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final Function(int) _onDelete;
  final Function(int) _onEdit;

  const ExerciseListItem(this.exercise, this._onDelete, this._onEdit);

  @override
  Widget build(BuildContext context) {
    final description = exercise.description ?? '';
    return Slidable(
      key: ValueKey(exercise.id!),
      groupTag: 'exercises',
      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            flex: 1,
            onPressed: (_) => _onDelete(exercise.id!),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: (_) => _onEdit(exercise.id!),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      child: ListTile(
        title: Text(exercise.name ?? 'No name'),
        subtitle: Text(description.length >= 20
            ? description.replaceRange(20, description.length, '...')
            : description),
        leading: Container(
          margin: EdgeInsets.only(top: 8),
          child: TwoLettersIcon(exercise.name ?? ''),
        ),
      ),
    );
  }
}
