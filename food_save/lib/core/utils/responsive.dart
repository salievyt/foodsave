import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static double hPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w <= 360) return 14;
    if (w <= 420) return 18;
    if (w <= 600) return 20;
    return 24;
  }
}
