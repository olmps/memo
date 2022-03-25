import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/memo_theme_data.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/home/progress_vm.dart';
import 'package:memo/application/widgets/theme/stacked_circular_progress.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';

class ProgressPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final state = ref.watch(progressVM);
    if (state is LoadingProgressState) {
      return const Center(child: CircularProgressIndicator());
    }

    final loadedState = state as LoadedProgressState;

    final firstRowParallelContainers = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: _buildTotalTimeContainer(context, theme, timeProgress: loadedState.timeProgress),
        ),
        context.horizontalBox(Spacing.medium),
        Flexible(
          child: _ProgressContainer(
            title: _buildAlternateStyleTextBox(
              context,
              theme,
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
          // Wrapping in an `IntrinsicHeight`, otherwise the column will vertically expand to infinity.
          IntrinsicHeight(child: firstRowParallelContainers),
          for (final difficulty in loadedState.executionsPercentage.keys) ...[
            context.verticalBox(Spacing.medium),
            _buildDifficultyProgressContainer(
              context,
              theme,
              difficulty,
              amountPercentage: loadedState.executionsPercentage[difficulty]!,
            ),
          ]
        ],
      ).withSymmetricalPadding(context, vertical: Spacing.large, horizontal: Spacing.medium),
    );
  }

  Widget _buildDifficultyProgressContainer(
    BuildContext context,
    MemoThemeData theme,
    MemoDifficulty difficulty, {
    required double amountPercentage,
  }) {
    final readablePercentage = (amountPercentage * 100).round().toString();

    return _ProgressContainer(
      leading: StackedCircularProgress(
        progressValue: amountPercentage,
        semanticLabel: strings.circularIndicatorMemoAnswersLabel(difficulty),
        child: Image.asset(images.memoDifficultyEmoji(difficulty)),
      ),
      title: _buildAlternateStyleTextBox(
        context,
        theme,
        texts: [readablePercentage, strings.percentSymbol],
      ),
      description: strings.answeredMemos(difficulty).toUpperCase(),
    );
  }

  Widget _buildTotalTimeContainer(BuildContext context, MemoThemeData theme, {required TimeProgress timeProgress}) {
    final textComponents = <String>[];
    if (timeProgress.hours != null || timeProgress.hasOnlySeconds) {
      final rawHours = timeProgress.hours ?? 0;
      textComponents.addAll([rawHours.toString(), strings.hoursSymbol]);
    }

    if (timeProgress.minutes != null) {
      textComponents.addAll([timeProgress.minutes.toString(), strings.minutesSymbol]);
    }

    return _ProgressContainer(
      title: _buildAlternateStyleTextBox(context, theme, texts: textComponents),
      description: strings.progressTotalStudyTime.toUpperCase(),
    );
  }

  /// Creates a [FittedBox] that styles its [texts] argument in an interspaced fashion.
  ///
  /// For each text in [texts], a style is specified based on its index being an odd/even number.
  Widget _buildAlternateStyleTextBox(BuildContext context, MemoThemeData theme, {required List<String> texts}) {
    assert(texts.isNotEmpty);

    final spans = <TextSpan>[];
    final textTheme = Theme.of(context).textTheme;
    final titleColor = theme.secondarySwatch.shade400;
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

    // Use a `FittedBox` to resize its text width if not enough horizontal space is available.
    return FittedBox(child: Text.rich(TextSpan(children: spans), maxLines: 1));
  }
}

/// Generic container that wraps progress-related information.
class _ProgressContainer extends ConsumerWidget {
  const _ProgressContainer({required this.title, required this.description, this.leading, Key? key}) : super(key: key);

  /// Optional leading widget before the textual contents of this widget.
  final Widget? leading;

  final Widget title;

  /// Additional description that goes below [title].
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    // Vertical wrapper for both `title` (with `titleSuffix` if available) and `description`.
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

    final memoTheme = ref.watch(themeController);
    final borderColor = memoTheme.neutralSwatch.shade800;
    final decoration = BoxDecoration(
      borderRadius: dimens.genericRoundedElementBorderRadius,
      border: Border.all(color: borderColor, width: dimens.cardBorderWidth),
    );

    return DecoratedBox(
      decoration: decoration,
      child: contents.withAllPadding(context, Spacing.large),
    );
  }
}
