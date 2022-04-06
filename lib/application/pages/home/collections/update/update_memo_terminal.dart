import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
class UpdateMemoTerminal extends HookConsumerWidget {
  const UpdateMemoTerminal({
    required this.memoIndex,
    this.questionController,
    this.answerController,
    this.onRemove,
    this.scrollController,
  });

  /// The index of the current memo in the `Collection` `Memo`'s list.
  final int memoIndex;

  final RichTextFieldController? questionController;
  final RichTextFieldController? answerController;

  /// Triggers when the current memo should be removed from the Collection Memos.
  final VoidCallback? onRemove;

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final textTheme = Theme.of(context).textTheme;

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

    final trashButton = CustomTextButton(
      color: theme.destructiveSwatch,
      text: strings.remove.toUpperCase(),
      leadingAsset: images.trashAsset,
      onPressed: onRemove != null ? () => _removeDialogConfirmation(context) : null,
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

  Future<void> _removeDialogConfirmation(BuildContext context) => showDestructiveOperationModalBottomSheet(
        context,
        title: strings.removeMemoTitle,
        message: strings.removeMemoMessage,
        destructiveActionTitle: strings.remove.toUpperCase(),
        cancelActionTitle: strings.cancel.toUpperCase(),
        onDestructiveTapped: () {
          // We can bang-operator the `onRemove` cause it's only called when the button is available, which is also
          // determined by this same property.
          onRemove!();
          Navigator.of(context).pop();
        },
        onCancelTapped: Navigator.of(context).pop,
      );
}
