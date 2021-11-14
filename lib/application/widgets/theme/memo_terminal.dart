import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/utils/bottom_sheet.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';
import 'package:memo/application/widgets/theme/terminal_window.dart';

/// A terminal-styled component that presents a `Memo` question and answer that can be updated.
///
/// Use [questionController] and [answerController] to control the Memo content being edited.
class MemoTerminal extends ConsumerWidget {
  const MemoTerminal({
    required this.memoIndex,
    this.questionController,
    this.answerController,
    this.onRemove,
    this.scrollController,
  });

  /// The index of the current memo in the `Collection` `Memo`'s list.
  final int memoIndex;

  /// Controls the `Memo` question content.
  final TextEditingController? questionController;

  /// Controls the `Memo` answer content.
  final TextEditingController? answerController;

  /// Triggers when the current memo should be removed from the Collection Memos.
  final VoidCallback? onRemove;

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = useTheme(ref);
    final textTheme = Theme.of(context).textTheme;

    final questionController = this.questionController ?? useTextEditingController();
    final questionTitle = Text(
      strings.updateMemoQuestionTitle(memoIndex),
      style: textTheme.bodyText1?.copyWith(color: theme.secondarySwatch),
    );
    final questionField = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        questionTitle,
        context.verticalBox(Spacing.small),
        RichTextField(
          modalTitle: questionTitle,
          placeholder: strings.updateMemoQuestionPlaceholder,
          controller: questionController,
        ),
      ],
    );

    final answerController = this.answerController ?? useTextEditingController();
    final answerTitle = Text(
      strings.updateMemoAnswer,
      style: textTheme.bodyText1?.copyWith(color: theme.primarySwatch),
    );
    final answerField = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        answerTitle,
        context.verticalBox(Spacing.small),
        RichTextField(
          modalTitle: answerTitle,
          placeholder: strings.updateMemoAnswerPlaceholder,
          controller: answerController,
        ),
      ],
    );

    Future<void> removeDialogConfirmation() => showDestructiveOperationModalBottomSheet(
          context,
          ref,
          title: strings.removeMemoTitle,
          message: strings.removeMemoMessage,
          destructiveActionTitle: strings.remove.toUpperCase(),
          cancelActionTitle: strings.cancel.toUpperCase(),
          onDestructiveTapped: () {
            onRemove!();
            Navigator.of(context).pop();
          },
          onCancelTapped: Navigator.of(context).pop,
        );

    final trashButton = CustomTextButton(
      color: theme.destructiveSwatch,
      text: strings.remove.toUpperCase(),
      leadingAsset: images.trashAsset,
      onPressed: onRemove != null ? removeDialogConfirmation : null,
    );

    final borderColor = theme.neutralSwatch.shade700;
    final fadeGradient = [theme.neutralSwatch.shade900, theme.neutralSwatch.shade900.withOpacity(0)];
    return TerminalWindow(
      borderColor: borderColor,
      fadeGradient: fadeGradient,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: dimens.terminalWindowHeaderHeight),
            questionField,
            context.verticalBox(Spacing.large),
            answerField,
            context.verticalBox(Spacing.large),
            trashButton,
          ],
        ).withAllPadding(context, Spacing.medium),
      ),
    );
  }
}
