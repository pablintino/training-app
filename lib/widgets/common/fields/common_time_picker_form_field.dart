import 'package:flutter/material.dart';
import 'package:training_app/widgets/time_picker_widget.dart';

class CommonTimePickerFormField extends StatelessWidget {
  final String label;
  final Function(int?) onChange;
  final TextEditingController controller;
  final int? valueSecs;

  const CommonTimePickerFormField(
      {Key? key,
      required this.label,
      this.valueSecs,
      required this.onChange,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          labelText: label,
          hintText: label,
          suffixIcon: IconButton(
              icon: Icon(Icons.timer),
              onPressed: () => TimePickerWidget.showPickerDialog(
                      context, "Select ${label.toLowerCase()}",
                      initialValueSeconds: valueSecs)
                  .then((value) => onChange(value)))),

// Note: This 2 props makes this seem disabled
      enableInteractiveSelection: false,
      controller: controller,
// will disable paste operation
      focusNode: new _AlwaysDisabledFocusNode(),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
    );
  }
}

class _AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
