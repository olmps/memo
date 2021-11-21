import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/theme_controller.dart';

/// A container that decorates [body] with a terminal style.
class TerminalWindow extends StatelessWidget {
  const TerminalWindow({required this.body, required this.borderColor, required this.fadeGradient});

  final Widget body;
  final Color borderColor;

  /// Dim content in vertical axis when [body] is scrollable.
  final List<Color> fadeGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: dimens.executionsTerminalBorderRadius,
        border: Border.all(
          color: borderColor,
          width: dimens.executionsTerminalBorderWidth,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: ClipRRect(child: body)),
          Positioned(left: 0, top: 0, right: 0, child: _TerminalHeader(fadeGradient: fadeGradient)),
        ],
      ),
    );
  }
}

class _TerminalHeader extends ConsumerWidget {
  const _TerminalHeader({required this.fadeGradient});

  final List<Color> fadeGradient;
  static const _actionsAmount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);

    final pseudoActions = List.generate(
      _actionsAmount,
      (index) => Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: theme.neutralSwatch.shade700),
        height: dimens.executionsTerminalActionDiameter,
        width: dimens.executionsTerminalActionDiameter,
      ),
    );

    return Container(
      height: dimens.terminalWindowHeaderHeight,
      decoration: BoxDecoration(
        borderRadius: dimens.executionsTerminalBorderRadius,
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: fadeGradient),
      ),
      child: Row(
        children: [
          for (final pseudoAction in pseudoActions) ...[
            pseudoAction,
            context.horizontalBox(Spacing.xxSmall),
          ]
        ],
      ).withOnlyPadding(context, left: Spacing.medium),
    );
  }
}
