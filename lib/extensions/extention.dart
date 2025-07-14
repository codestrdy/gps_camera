import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ContextX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
}

extension DoubleX on num {
  double sp(BuildContext context) {
    double screenWidth = context.screenSize.width;
    const double baseScreenWidth = 375.0; // Standard screen width
    double scaleFactor = screenWidth / baseScreenWidth;
    return this * scaleFactor;
  }
}

extension DateFormatX on DateTime {
  String get formatted => DateFormat('dd/MM/yyy HH:mm').format(this);
}
