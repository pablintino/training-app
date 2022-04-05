import 'package:flutter/material.dart';
import 'dart:math';

class CustomHeightClipper extends CustomClipper<Rect> {
  final double clipHeight;

  CustomHeightClipper(this.clipHeight);

  @override
  getClip(Size size) {
    double top = max(size.height - clipHeight, 0);
    Rect rect = Rect.fromLTRB(0.0, top, size.width, size.height);
    return rect;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
