import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonTextFormField extends TextFormField {
  CommonTextFormField(
      {required Function(String?) onChanged,
      String? label,
      String? hint,
      String? validationMessage,
      TextEditingController? controller,
      FocusNode? focusNode,
      List<TextInputFormatter>? inputFormatters,
      TextStyle? style,
      int? maxLines,
      TextAlign? textAlign,
      bool autofocus = false,
      bool enabled = true})
      : super(
            enabled: enabled,
            controller: controller,
            keyboardType: TextInputType.name,
            onChanged: (value) => onChanged(value),
            textInputAction: TextInputAction.next,
            inputFormatters: inputFormatters,
            autofocus: autofocus,
            focusNode: focusNode,
            maxLines: maxLines,
            textAlign: textAlign ?? TextAlign.start,
            style: style,
            decoration: InputDecoration(
                hintText: enabled ? hint : null,
                labelText:  label,
                errorText: enabled ? validationMessage : null));
}
