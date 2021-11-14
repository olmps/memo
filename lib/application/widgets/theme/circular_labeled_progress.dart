import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/animatable_progress.dart';

/// Centers a styled [Text] element above a [AnimatableCircularProgress] with [progressValue].
class CircularLabeledProgress extends ConsumerWidget {
  const CircularLabeledProgress({
    required this.progressValue,
    required this.centerLabel,
    required this.semanticLabel,
    Key? key,
  }) : super(key: key);

  final double progressValue;
  final String centerLabel;
  final String semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoTheme = useTheme(ref);
    final centerLabelTheme = Theme.of(context).textTheme.headline4;

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
            child: Align(child: Text(centerLabel, style: centerLabelTheme)),
          ),
        ],
      ),
    );
  }
}
