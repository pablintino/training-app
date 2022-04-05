import 'package:flutter/material.dart';

class FixedColorRoundIcon extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const FixedColorRoundIcon(this.text, this.color, this.textColor, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: 50.0,
      //height: 50.0,
      padding: const EdgeInsets.all(15.0),
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: new Text(text,
          style: new TextStyle(color: textColor, fontSize: 20.0)),
    );
  }
}
