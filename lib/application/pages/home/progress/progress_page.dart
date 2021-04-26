import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/home/progress_vm.dart';
import 'package:memo/application/widgets/animatable_progress.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';

class ProgressPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = useProvider(progressVM.state);
    if (state is LoadingProgressState) {
      return const Center(child: CircularProgressIndicator());
    }

    final loadedState = state as LoadedProgressState;

    final firstRowParallelContainers = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: _buildTotalTimeContainer(context, timeProgress: loadedState.timeProgress),
        ),
        context.horizontalBox(Spacing.medium),
        Flexible(
          child: _ProgressContainer(
            title: _buildAlternateStyleTextBox(
              context,
              texts: [loadedState.totalExecutions.toString()],
            ),
            description: strings.progressTotalMemos.toUpperCase(),
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          // Wrapping in an `IntrinsicHeight`, otherwise the column will vertically expand to infinity
          IntrinsicHeight(child: firstRowParallelContainers),
          for (final difficulty in loadedState.executionsPercentage.keys) ...[
            context.verticalBox(Spacing.medium),
            _buildDifficultyProgressContainer(
              context,
              difficulty,
              amountPercentage: loadedState.executionsPercentage[difficulty]!,
            ),
          ]
        ],
      ).withSymmetricalPadding(context, vertical: Spacing.large, horizontal: Spacing.medium),
    );
  }

  Widget _buildDifficultyProgressContainer(BuildContext context, MemoDifficulty difficulty,
      {required double amountPercentage}) {
    final readablePercentage = (amountPercentage * 100).round().toString();

    return _ProgressContainer(
      leading: _buildCircularProgress(
        context,
        progressValue: amountPercentage,
        centerLabel: strings.progressDifficultyEmoji(difficulty),
        semanticLabel: strings.progressIndicatorLabel(difficulty),
      ),
      title: _buildAlternateStyleTextBox(
        context,
        texts: [readablePercentage, strings.percentSymbol],
      ),
      description: strings.progressTotalCompletedMemos(difficulty),
    );
  }

  Widget _buildTotalTimeContainer(BuildContext context, {required TimeProgress timeProgress}) {
    final textComponents = <String>[];
    if (timeProgress.hours != null || timeProgress.isEmpty) {
      final rawHours = timeProgress.hours ?? 0;
      textComponents.addAll([rawHours.toString(), strings.hoursSymbol]);
    }

    if (timeProgress.minutes != null) {
      textComponents.addAll([timeProgress.minutes.toString(), strings.minutesSymbol]);
    }

    return _ProgressContainer(
      title: _buildAlternateStyleTextBox(context, texts: textComponents),
      description: strings.progressTotalStudyTime.toUpperCase(),
    );
  }

  /// Creates a [FittedBox] that styles its [texts] argument with in an interspaced fashion
  ///
  /// For each text (index) in [texts] a style for that particular text is specified, wrapping it all around a single
  /// [TextSpan], which corresponds to the child of the [FittedBox].
  Widget _buildAlternateStyleTextBox(BuildContext context, {required List<String> texts}) {
    assert(texts.isNotEmpty);

    final spans = <TextSpan>[];
    final textTheme = Theme.of(context).textTheme;
    final titleColor = useTheme().secondarySwatch.shade400;
    for (var index = 0; index < texts.length; ++index) {
      spans.add(
        TextSpan(
          text: texts[index],
          style: index.isOdd
              ? textTheme.headline4?.copyWith(color: titleColor)
              : textTheme.headline3?.copyWith(color: titleColor),
        ),
      );
    }

    // Use a `FittedBox` to resize its text width if not enough horizontal space is available
    return FittedBox(child: Text.rich(TextSpan(children: spans), maxLines: 1));
  }

  Widget _buildCircularProgress(
    BuildContext context, {
    required double progressValue,
    required String centerLabel,
    required String semanticLabel,
  }) {
    final memoTheme = useTheme();
    final centerLabelTheme = Theme.of(context).textTheme.headline4;

    return SizedBox(
      width: dimens.progressCircularProgressSize,
      height: dimens.progressCircularProgressSize,
      child: Stack(
        children: [
          AnimatableCircularProgress(
            value: progressValue,
            animationCurve: dimens.defaultAnimationCurve,
            animationDuration: dimens.defaultAnimatableProgressDuration,
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

/// Generic container that wraps a progress-related information
class _ProgressContainer extends HookWidget {
  const _ProgressContainer({required this.title, required this.description, this.leading, Key? key}) : super(key: key);

  /// Optional leading widget before the textual contents of this widget
  final Widget? leading;

  /// Primary emphasized for this widget
  final Widget title;

  /// Additional description that goes below the [title]
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Vertical wrapper for both `title` (with `titleSuffix` if available) and `description`
    final leftContents = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        context.verticalBox(Spacing.xSmall),
        Text(description, style: textTheme.caption),
      ],
    );

    final contents = Row(
      children: [
        if (leading != null) ...[
          leading!,
          context.horizontalBox(Spacing.large),
        ],
        Flexible(child: leftContents)
      ],
    );

    final memoTheme = useTheme();
    final borderColor = memoTheme.neutralSwatch.shade800;
    final decoration = BoxDecoration(
      borderRadius: dimens.genericRoundedElementBorderRadius,
      border: Border.all(color: borderColor, width: dimens.cardBorderWidth),
    );

    return Container(
      decoration: decoration,
      child: contents.withAllPadding(context, Spacing.large),
    );
  }
}
