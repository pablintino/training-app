import 'package:flutter/material.dart';
import 'package:training_app/models/exercises_models.dart';
import 'package:training_app/widgets/two_letters_icon/two_letters_icon.dart';

class ExerciseListItem extends StatelessWidget {
  final Exercise exercise;

  const ExerciseListItem(this.exercise);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(exercise.name ?? 'No name'),
      subtitle: Text(exercise.description ?? ''),
      leading: Container(
        margin: EdgeInsets.only(top: 8),
        child: TwoLettersIcon(exercise.name ?? ''),
      ),
    );
  }
}
