import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/memo_theme_data.dart';
import 'package:memo/application/theme/theme_controller.dart';

/// Decorates a [Container] with custom layout specs.
///
/// This themes a container that usually is placed in the top section of any layout, as it themes its contents with a
/// border below its [child].
class ThemedTopContainer extends ConsumerWidget {
  const ThemedTopContainer({required this.child}) : super();

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: _useThemedBorderSide(theme)),
      ),
      child: child,
    );
  }
}

/// Decorates a [Container] with custom layout specs.
///
/// This container should be placed in the bottom "section" of any layout, as it themes its contents with a border above
/// its [child].
class ThemedBottomContainer extends ConsumerWidget {
  const ThemedBottomContainer({required this.child}) : super();

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: _useThemedBorderSide(theme)),
      ),
      child: child,
    );
  }
}

// Should always be called in a hook context.
BorderSide _useThemedBorderSide(MemoThemeData theme) => BorderSide(
      width: dimens.genericBorderHeight,
      color: theme.neutralSwatch.shade700,
    );
