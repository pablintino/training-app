import 'package:training_app/utils/form_utils.dart';

enum ExerciseNameInputError { empty, alreadyExists }

class ExerciseNameField extends FormField<String, ExerciseNameInputError> {
  ExerciseNameField({String? value}) : super(value: value);

  ExerciseNameField.createInvalidFrom(
      ExerciseNameField form, ExerciseNameInputError error,
      {value})
      : super.createInvalidFrom(form, error, value: value);

  ExerciseNameField.createValidFrom(ExerciseNameField form, {value})
      : super.createValidFrom(form, value: value);
}

enum ExerciseDescriptionInputError { empty }

class ExerciseDescriptionField
    extends FormField<String, ExerciseDescriptionInputError> {
  ExerciseDescriptionField({String? value}) : super(value: value);

  ExerciseDescriptionField.createInvalidFrom(
      ExerciseDescriptionField form, ExerciseDescriptionInputError error,
      {value})
      : super.createInvalidFrom(form, error, value: value);

  ExerciseDescriptionField.createValidFrom(ExerciseDescriptionField form,
      {value})
      : super.createValidFrom(form, value: value);
}
