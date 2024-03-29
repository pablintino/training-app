abstract class FormField<T, E> {
  final T? value;
  final bool valid;
  final E? status;
  final bool dirty;

  FormField({value, status})
      : dirty = false,
        value = value,
        valid = false,
        status = status;

  FormField.createInvalidFrom(FormField<T, E> form, E status, {value})
      : status = status,
        dirty = true,
        valid = false,
        value = value ?? form.value;

  FormField.createValidFrom(FormField<T, E> form, {value})
      : status = null,
        dirty = true,
        valid = true,
        value = value ?? form.value;
}

///// Commonly used Types
enum ValidationError {
  empty,
  alreadyExists,
  minLengthRequired,
  maxLengthExceed,
  pastTime
}

class StringField extends FormField<String, ValidationError> {
  StringField({value, status}) : super(value: value);

  @override
  StringField.createInvalidFrom(StringField form, ValidationError status,
      {value})
      : super.createInvalidFrom(form, status, value: value);

  @override
  StringField.createValidFrom(StringField form, {value})
      : super.createValidFrom(form, value: value);
}
