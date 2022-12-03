import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonNumericFormField extends TextFormField {
  CommonNumericFormField(
      {required Function(int?) onChanged,
      required String label,
      String? hint,
      TextEditingController? controller,
      FocusNode? focusNode,
      List<TextInputFormatter>? inputFormatters,
      bool autofocus = false})
      : super(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: autofocus,
            focusNode: focusNode,
            decoration: InputDecoration(hintText: hint, labelText: label),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              if (inputFormatters != null) ...inputFormatters
            ],
            onChanged: (value) =>
                onChanged(value.isNotEmpty ? int.tryParse(value) : null));
}
