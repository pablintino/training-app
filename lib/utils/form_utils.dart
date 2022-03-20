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

  FormField.invalidate(FormField<T, E> form, E status, {value})
      : status = status,
        dirty = true,
        valid = false,
        value = value ?? form.value;

  FormField.valid(FormField<T, E> form, {value})
      : status = null,
        dirty = true,
        valid = true,
        value = value ?? form.value;
}
