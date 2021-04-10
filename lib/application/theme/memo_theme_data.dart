import 'package:flutter/material.dart';

enum MemoTheme { classic }

/// Wraps all fundamental swatches for a `MemoTheme`
///
/// The only purpose of having this customized set of theme-related properties is due to the fact that the material's
/// `ThemeData` doesn't support custom properties. While there are workarounds, they don't quite work for applications
/// that require multiple sub-themes.
///
/// There is an [open issue](https://github.com/flutter/flutter/issues/31522) in flutter's framework, tracking this
/// missing feature.
class MemoThemeData {
  const MemoThemeData(
    this.theme, {
    required this.primarySwatch,
    required this.secondarySwatch,
    required this.neutralSwatch,
  });

  final MemoTheme theme;

  final MaterialColor primarySwatch;
  final MaterialColor secondarySwatch;
  final MaterialColor neutralSwatch;
}
