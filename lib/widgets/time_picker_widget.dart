import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:training_app/utils/conversion.dart';

class TimePickerWidget extends StatefulWidget {
  final String title;
  final int? initialValueSeconds;

  const TimePickerWidget._(this.title, {Key? key, this.initialValueSeconds})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _TimePickerWidgetState(initialValueSeconds);

  static Future<int?> showPickerDialog(BuildContext context, String title,
      {int? initialValueSeconds}) {
    return showDialog<int?>(
        context: context,
        builder: (_) => TimePickerWidget._(
              title,
              initialValueSeconds: initialValueSeconds,
            ));
  }
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  final int? initialValueSeconds;

  late TextEditingController hoursController;
  late TextEditingController minsController;

  late TextEditingController secsController;
  final hoursFocusNode = FocusNode();
  final minutesFocusNode = FocusNode();
  final secondsFocusNode = FocusNode();

  _TimePickerWidgetState(this.initialValueSeconds) {
    final initialValueTuple = initialValueSeconds != null
        ? ConversionUtils.secondsToSecMinHours(initialValueSeconds!)
        : null;
    hoursController = TextEditingController(
        text: initialValueTuple?.item3.toString() ?? null);
    minsController = TextEditingController(
        text: initialValueTuple?.item2.toString() ?? null);
    secsController = TextEditingController(
        text: initialValueTuple?.item1.toString() ?? null);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            child: Row(
          children: [
            _buildInputField(context, "Hour", hoursController, 99,
                textInputAction: TextInputAction.next,
                autofocus: true,
                focusNode: hoursFocusNode,
                nextFocusNode: minutesFocusNode),
            _buildTimeSeparator(),
            _buildInputField(context, "Minutes", minsController, 59,
                textInputAction: TextInputAction.next,
                focusNode: minutesFocusNode,
                nextFocusNode: secondsFocusNode,
                previousFocusNode: hoursFocusNode),
            _buildTimeSeparator(),
            _buildInputField(context, "Seconds", secsController, 59,
                focusNode: secondsFocusNode,
                previousFocusNode: minutesFocusNode),
          ],
        )),
      ),
      actions: [
        TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context, null);
            }),
        ElevatedButton(
            child: Text("Save"),
            onPressed: () {
              final hours = hoursController.text.isNotEmpty
                  ? int.parse(hoursController.text)
                  : 0;
              final mins = minsController.text.isNotEmpty
                  ? int.parse(minsController.text)
                  : 0;
              final secs = secsController.text.isNotEmpty
                  ? int.parse(secsController.text)
                  : 0;
              final totalSecs = hours * 3600 + mins * 60 + secs;
              Navigator.pop(context, totalSecs);
            }),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            ":",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
        SizedBox(
          height: 18,
        )
      ],
    );
  }

  Expanded _buildInputField(BuildContext context, String name,
      TextEditingController controller, int max,
      {TextInputAction? textInputAction,
      bool? autofocus,
      FocusNode? focusNode,
      FocusNode? nextFocusNode,
      FocusNode? previousFocusNode}) {
    return Expanded(
      child: Column(
        children: [
          TextFormField(
            focusNode: focusNode,
            autofocus: autofocus ?? false,
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textInputAction: textInputAction,
            onChanged: (val) {
              final valueIsDoubleZero = "00" == val;
              if (val.isNotEmpty && int.parse(val) > max) {
                controller.clear();
              } else if (nextFocusNode != null &&
                  (val.length == 2 ||
                      0.toString() == val ||
                      valueIsDoubleZero)) {
                FocusScope.of(context).requestFocus(nextFocusNode);
              } else if (val.isEmpty && previousFocusNode != null) {
                FocusScope.of(context).requestFocus(previousFocusNode);
              }

              // Double zero is a single zero always. Replace before repainting
              if (valueIsDoubleZero) {
                controller.text = "0";
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 4, left: 2),
                child: Text(
                  name,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Expanded(child: Container())
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    hoursController.dispose();
    minsController.dispose();
    secsController.dispose();
    hoursFocusNode.dispose();
    minutesFocusNode.dispose();
    secondsFocusNode.dispose();
    super.dispose();
  }
}
