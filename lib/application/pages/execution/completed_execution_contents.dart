import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/memo_theme_data.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/utils/scaffold_messenger.dart';
import 'package:memo/application/view-models/execution/collection_execution_vm.dart';
import 'package:memo/application/widgets/animatable_progress.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/application/widgets/theme/link.dart';
import 'package:memo/application/widgets/theme/stacked_circular_progress.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';

/// Contents (non-Scaffold) of a execution that has been completed.
class CompletedExecutionContents extends ConsumerWidget {
  const CompletedExecutionContents(this.state, {required this.onBackTap});

  final FinishedCollectionExecutionState state;

  /// Callback for a non-appbar tap to back.
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);

    final performanceSection = _buildPerformanceSection(context, theme);
    final completionSection = _buildCompletionSection(context, ref, theme);
    final backButton = PrimaryElevatedButton(
      onPressed: onBackTap,
      text: strings.executionBackToCollections.toUpperCase(),
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          _Header(collectionName: state.collectionName).withOnlyPadding(context, bottom: Spacing.xLarge),
          _wrapInVerticalSection(performanceSection.withSymmetricalPadding(context, vertical: Spacing.xLarge), theme),
          _wrapInVerticalSection(completionSection.withSymmetricalPadding(context, vertical: Spacing.xLarge), theme),
          _wrapInVerticalSection(backButton.withSymmetricalPadding(context, vertical: Spacing.xLarge), theme),
        ],
      ).withAllPadding(context, Spacing.medium),
    );
  }

  Widget _buildSectionTitle(BuildContext context, MemoThemeData theme, String text) => Text(
        text,
        style: Theme.of(context).textTheme.subtitle1?.copyWith(color: theme.neutralSwatch.shade300),
      );

  Widget _wrapInVerticalSection(Widget child, MemoThemeData theme) {
    final divider = Container(height: dimens.executionsCompletionDividerHeight, color: theme.neutralSwatch);
    return Column(children: [divider, child]);
  }

  Widget _buildPerformanceSection(BuildContext context, MemoThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(context, theme, strings.executionYourPerformance),
        context.verticalBox(Spacing.medium),
        // Wrapping in an `IntrinsicHeight`, otherwise the child will vertically expand to infinity.
        IntrinsicHeight(
          child: _PerformanceIndicators(
            difficultiesIndicators: state.availableDifficulties,
            answerValueForDifficulty: state.progressValueForDifficulty,
            readableAnswersForDifficulty: state.readableProgressForDifficulty,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionSection(BuildContext context, WidgetRef ref, MemoThemeData theme) {
    final String sectionTitle;
    final double linearProgressValue;
    final String progressSemanticValue;
    if (state is FinishedIncompleteCollectionExecutionState) {
      final incompleteState = state as FinishedIncompleteCollectionExecutionState;
      sectionTitle = strings.collectionCompletionProgress(
        current: incompleteState.uniqueExecutedMemos,
        target: incompleteState.totalUniqueMemos,
      );
      linearProgressValue = incompleteState.completionLevel;
      progressSemanticValue = strings.linearIndicatorCollectionCompletionLabel(incompleteState.readableCompletion);
    } else if (state is FinishedCompleteCollectionExecutionState) {
      final completeState = state as FinishedCompleteCollectionExecutionState;
      sectionTitle = strings.recallLevel;
      linearProgressValue = completeState.recallLevel;
      progressSemanticValue = strings.linearIndicatorCollectionRecallLabel(completeState.readableRecall);
    } else {
      throw InconsistentStateError.layout(
        'Unexpected `FinishedCollectionExecutionState` subtype: ${state.runtimeType}',
      );
    }

    final showsRecallLevelLink = state is FinishedCompleteCollectionExecutionState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(context, theme, sectionTitle),
        context.verticalBox(Spacing.medium),
        AnimatableLinearProgress(
          value: linearProgressValue,
          animationCurve: anims.defaultAnimationCurve,
          animationDuration: anims.defaultAnimatableProgressDuration,
          lineSize: dimens.progressCircularProgressLineWidth,
          lineColor: theme.secondarySwatch.shade400,
          lineBackgroundColor: theme.neutralSwatch.shade800,
          semanticLabel: progressSemanticValue,
        ),
        context.verticalBox(Spacing.medium),
        if (showsRecallLevelLink)
          UrlLinkButton(
            strings.faqUrl,
            text: strings.executionWhatIsRecallLevel,
            onFailLaunchingUrl: (exception) => showExceptionSnackBar(ref, exception),
          ),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.collectionName});

  final String collectionName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoTheme = ref.watch(themeController);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(strings.partyPopper, style: TextStyle(fontSize: dimens.executionsHeaderEmojiTextSize)),
        context.verticalBox(Spacing.xLarge),
        Text(
          strings.executionWellDone,
          style: textTheme.subtitle1?.copyWith(color: memoTheme.primarySwatch.shade400),
          textAlign: TextAlign.center,
        ),
        context.verticalBox(Spacing.small),
        Text(
          strings.executionImprovedKnowledgeDescription,
          style: textTheme.subtitle1?.copyWith(color: memoTheme.neutralSwatch.shade400),
          textAlign: TextAlign.center,
        ),
        context.verticalBox(Spacing.large),
        Text(
          '# $collectionName',
          style: textTheme.headline6,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Displays a list of horizontal progress indicators, given the answers in this execution session.
class _PerformanceIndicators extends ConsumerWidget {
  const _PerformanceIndicators({
    required this.difficultiesIndicators,
    required this.answerValueForDifficulty,
    required this.readableAnswersForDifficulty,
  });

  final List<MemoDifficulty> difficultiesIndicators;

  /// Requests the percentage (from `0` to `1`) of answers for this `MemoDifficulty`.
  final double Function(MemoDifficulty) answerValueForDifficulty;

  /// Requests a readable representation of this answer's value percentage.
  final String Function(MemoDifficulty) readableAnswersForDifficulty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final memoTheme = ref.watch(themeController);

    final performanceIndicators = difficultiesIndicators.map((difficulty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StackedCircularProgress(
            progressValue: answerValueForDifficulty(difficulty),
            semanticLabel: strings.circularIndicatorMemoAnswersLabel(difficulty),
            child: Image.asset(images.memoDifficultyEmoji(difficulty)),
          ),
          context.verticalBox(Spacing.small),
          Text(
            readableAnswersForDifficulty(difficulty) + strings.percentSymbol,
            style: textTheme.subtitle1?.copyWith(color: memoTheme.secondarySwatch.shade400),
            textAlign: TextAlign.center,
          ),
          context.verticalBox(Spacing.xxSmall),
          Text(
            strings.answeredMemos(difficulty).toUpperCase(),
            style: textTheme.caption,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: performanceIndicators
          .mapIndexed(
            (index, widget) => [
              Flexible(child: widget),
              // Make sure to not add a padding to the last element.
              if (index != performanceIndicators.length - 1) context.horizontalBox(Spacing.xxxLarge),
            ],
          )
          .expand((element) => element)
          .toList(),
    );
  }
}
