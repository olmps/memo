import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/theme_controller.dart';

/// Decorates a [Container] with custom layout specs.
///
/// This themes a container that usually is placed in the top section of any layout, as it themes its contents with a
/// border below its [child].
class ThemedTopContainer extends HookWidget {
  const ThemedTopContainer({required this.child}) : super();

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: _useThemedBorderSide()),
      ),
      child: child,
    );
  }
}

/// Decorates a [Container] with custom layout specs.
///
/// This container should be placed in the bottom "section" of any layout, as it themes its contents with a border above
/// its [child].
class ThemedBottomContainer extends HookWidget {
  const ThemedBottomContainer({required this.child}) : super();

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: _useThemedBorderSide()),
      ),
      child: child,
    );
  }
}

// Should always be called in a hook context.
BorderSide _useThemedBorderSide() => BorderSide(
      width: dimens.genericBorderHeight,
      color: useTheme().neutralSwatch.shade700,
    );
