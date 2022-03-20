import 'package:training_app/utils/form_utils.dart';

enum ExerciseNameInputError { empty, alreadyExists }

class ExerciseNameField extends FormField<String, ExerciseNameInputError> {
  ExerciseNameField({String? value}) : super(value: value);

  ExerciseNameField.invalid(
      ExerciseNameField form, ExerciseNameInputError error,
      {value})
      : super.invalidate(form, error, value: value);

  ExerciseNameField.valid(ExerciseNameField form, {value})
      : super.valid(form, value: value);
}

enum ExerciseDescriptionInputError { empty }

class ExerciseDescriptionField
    extends FormField<String, ExerciseDescriptionInputError> {
  ExerciseDescriptionField({String? value}) : super(value: value);

  ExerciseDescriptionField.invalid(
      ExerciseDescriptionField form, ExerciseDescriptionInputError error,
      {value})
      : super.invalidate(form, error, value: value);

  ExerciseDescriptionField.valid(ExerciseDescriptionField form, {value})
      : super.valid(form, value: value);
}
