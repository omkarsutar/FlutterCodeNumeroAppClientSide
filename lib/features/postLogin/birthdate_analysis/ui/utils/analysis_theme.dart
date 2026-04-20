import 'package:flutter/material.dart';

class AnalysisTheme {
  static Color getAccent(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? const Color(0xFF8EA2D6)
        : const Color(0xFF5F78A8);
  }

  static Color getBodyText(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? const Color(0xFFD9E2F2)
        : const Color(0xFF55627A);
  }
}
