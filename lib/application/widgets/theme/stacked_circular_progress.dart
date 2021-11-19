import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/animatable_progress.dart';

/// Stacks a centered [child] on top of a [AnimatableCircularProgress] with [progressValue].
class StackedCircularProgress extends ConsumerWidget {
  const StackedCircularProgress({
    required this.progressValue,
    required this.semanticLabel,
    required this.child,
    Key? key,
  }) : super(key: key);

  final double progressValue;
  final String semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoTheme = ref.watch(themeController);

    return SizedBox(
      width: dimens.progressCircularProgressSize,
      height: dimens.progressCircularProgressSize,
      child: Stack(
        children: [
          AnimatableCircularProgress(
            value: progressValue,
            animationCurve: anims.defaultAnimationCurve,
            animationDuration: anims.defaultAnimatableProgressDuration,
            lineSize: dimens.progressCircularProgressLineWidth,
            lineColor: memoTheme.secondarySwatch.shade400,
            lineBackgroundColor: memoTheme.neutralSwatch.shade800,
            minSize: dimens.progressCircularProgressSize,
            semanticLabel: semanticLabel,
          ),
          Positioned.fill(
            child: Align(child: child),
          ),
        ],
      ),
    );
  }
}
