import 'package:flutter/material.dart';
import 'package:training_app/models/exercises_models.dart';

class ExerciseListItem extends StatelessWidget {
  final Exercise exercise;

  const ExerciseListItem(this.exercise);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(exercise.name ?? 'No name'),
      subtitle: Text(exercise.description ?? ''),
      childrenPadding: const EdgeInsets.all(16),
      leading: Container(
        margin: EdgeInsets.only(top: 8),
        child: Text(exercise.id.toString()),
      ),
      children: [
        Text(
          exercise.description ?? '',
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 20),
        Container()
      ],
    );
  }
}
