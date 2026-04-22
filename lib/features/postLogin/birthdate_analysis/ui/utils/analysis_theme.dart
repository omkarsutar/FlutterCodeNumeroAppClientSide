import 'package:flutter/material.dart';

class AnalysisTheme {
  static Color getAccent(ThemeData theme) {
    return theme.colorScheme.primary;
  }

  static Color getBodyText(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurfaceVariant;
  }
}
