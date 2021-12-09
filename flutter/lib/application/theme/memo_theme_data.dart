import 'package:flutter/material.dart';

enum MemoTheme { classic }

/// Wraps all custom properties for a particular [theme].
///
/// A workaround for material's lack of support for custom properties.
///
/// There is an [open issue](https://github.com/flutter/flutter/issues/31522) in flutter's framework tracking this
/// missing feature.
class MemoThemeData {
  const MemoThemeData(
    this.theme, {
    required this.primarySwatch,
    required this.secondarySwatch,
    required this.neutralSwatch,
    required this.destructiveSwatch,
  });

  final MemoTheme theme;

  final MaterialColor primarySwatch;
  final MaterialColor secondarySwatch;
  final MaterialColor neutralSwatch;
  final MaterialColor destructiveSwatch;
}
