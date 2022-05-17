import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class CustomHourPicker extends StatefulWidget {
  final DateTime? date;
  final DateTime? initDate;
  final String? title;
  final String? positiveButtonText;
  final String? negativeButtonText;
  final double? elevation;
  final TextStyle? positiveButtonStyle;
  final TextStyle? negativeButtonStyle;
  final TextStyle? titleStyle;
  final Function(BuildContext context, DateTime time)? onPositivePressed;
  final Function(BuildContext context)? onNegativePressed;

  const CustomHourPicker({
    Key? key,
    this.onPositivePressed,
    this.onNegativePressed,
    this.date,
    this.initDate,
    this.title,
    this.positiveButtonText,
    this.negativeButtonText,
    this.elevation,
    this.positiveButtonStyle,
    this.negativeButtonStyle,
    this.titleStyle,
  }) : super(key: key);

  @override
  _CustomHourPickerState createState() => _CustomHourPickerState();
}

class _CustomHourPickerState extends State<CustomHourPicker> {
  var hourValue = 12;
  var minValue = 30;
  var secValue = 0;
  DateTime time = DateTime(0);
  DateTime? date;
  DateTime? initDate;

  @override
  void initState() {
    super.initState();
    date = widget.date ?? DateTime.now();
    initDate = widget.date ?? DateTime.now();

    hourValue = date?.hour ?? hourValue;
    minValue = date?.minute ?? minValue;
    secValue = date?.second ?? secValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: widget.elevation ?? Theme.of(context).cardTheme.elevation,
      contentPadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitle(),
          const SizedBox(height: 15),
          _buildLineViewWidget(),
          const SizedBox(height: 10),
          buildClockNumbers(),
          const SizedBox(height: 10),
          _buildLineViewWidget(),
          // SizedBox(height: 15),
          _buildButtons()
        ],
      ),
    );
  }

  Row buildClockNumbers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberPicker(
          minValue: 00,
          maxValue: 23,
          zeroPad: true,
          itemWidth: 70,
          value: hourValue,
          infiniteLoop: true,
          onChanged: (value) {
            setState(() {
              hourValue = value;
            });
          },
        ),
        const Text(
          ":",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        NumberPicker(
          minValue: 00,
          maxValue: 59,
          itemWidth: 70,
          zeroPad: true,
          value: minValue,
          infiniteLoop: true,
          onChanged: (value) {
            setState(() {
              minValue = value;
            });
          },
        ),
        const Text(
          ":",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        NumberPicker(
          minValue: 00,
          maxValue: 59,
          zeroPad: true,
          itemWidth: 70,
          value: secValue,
          infiniteLoop: true,
          onChanged: (value) {
            setState(() {
              secValue = value;
            });
          },
        ),
      ],
    );
  }

  Text buildTitle() {
    return Text(
      widget.title ?? "Choose a time",
      textAlign: TextAlign.left,
      style: widget.titleStyle,
    );
  }

  Widget _buildButtons() {
    time = DateTime(1, 1, 1, hourValue, minValue);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onNegativePressed != null) _buildNegativeButton(),
        if (widget.onPositivePressed != null) _buildPositiveButton(),
      ],
    );
  }

  GestureDetector _buildPositiveButton() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        widget.onPositivePressed!(context, time);
      },
      child: Container(
        padding: const EdgeInsets.only(
          top: 15,
          left: 8,
          right: 5,
          bottom: 20,
        ),
        child: Text(
          widget.positiveButtonText ?? "Ok",
          style:
              widget.positiveButtonStyle ?? const TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  GestureDetector _buildNegativeButton() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        widget.onNegativePressed!(context);
      },
      child: Container(
        padding: const EdgeInsets.only(
          top: 15,
          left: 8,
          right: 5,
          bottom: 20,
        ),
        child: Text(
          widget.negativeButtonText ?? "Cancel",
          style:
              widget.negativeButtonStyle ?? const TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildLineViewWidget(
      {Color? color,
      double width = 2000,
      double boarder = 0,
      double height = 1,
      double bottom = 0,
      double top = 0,
      bool horizontal = true}) {
    return Container(
      margin: EdgeInsets.only(
          right: boarder, left: boarder, bottom: bottom, top: top),
      color: color ?? Colors.grey[300],
      width: horizontal ? width : 1,
      height: horizontal ? height : height,
    );
  }
}

Future<DateTime?> showCustomHourPicker(BuildContext context,
    {String? title, DateTime? initialDateTime}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomHourPicker(
        initDate: initialDateTime,
        title: title,
        elevation: 2,
        onPositivePressed: (context, time) => Navigator.pop(context, time),
        onNegativePressed: (context) => Navigator.pop(context),
      );
    },
  );
}
