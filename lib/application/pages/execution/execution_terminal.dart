import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/models/documents/document.dart' as quill_doc;
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';

/// Displays the [contents] of question/answer, with actionable buttons to evalute its recall difficulty
///
/// Its naming comes from the fact that its layout is drawn similar to most of the terminal applications.
class ExecutionTerminal extends HookWidget {
  const ExecutionTerminal({
    required this.contents,
    required this.isDisplayingQuestion,
    required this.collectionName,
    required this.onDifficultyMarked,
    required this.onActionTapped,
    this.markedAnswer,
    Key? key,
  }) : super(key: key);

  /// Raw representation for the current displayed contents (question or answer) of the terminal
  final List<Map<String, dynamic>> contents;

  /// If `isDisplayingQuestion` is `false`, shows the difficulty-marking actions
  final bool isDisplayingQuestion;

  /// Highlights the respective `MemoDifficulty` when displaying the difficulty-marking actions
  final MemoDifficulty? markedAnswer;

  /// The collection's name associated with this memo
  final String collectionName;

  /// Callback when a tap occurs on the `MemoDifficulty`
  final void Function(MemoDifficulty difficulty) onDifficultyMarked;

  /// Callback for the bottom action of this terminal
  final VoidCallback? onActionTapped;

  String get _collectionTitle => '# $collectionName';
  String get _contentsDescription => '## ${isDisplayingQuestion ? strings.executionQuestion : strings.executionAnswer}';

  /// Parses both collection title and description to `flutter-quill` format
  List get _headerFormattedToQuill => <dynamic>[
        {
          'insert': '$_collectionTitle\n\n',
        },
        {
          'insert': '$_contentsDescription\n',
        },
      ];

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final borderColor = theme.neutralSwatch.shade700;
    final fadeGradient = [theme.neutralSwatch.shade900, theme.neutralSwatch.shade900.withOpacity(0)];

    final terminalHeader = _TerminalHeader(fadeGradient: fadeGradient, borderColor: borderColor);
    // Middle faded transition to resembles that end the `contents`
    final terminalActionTransition = Container(
      height: dimens.executionsTerminalFadeHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: fadeGradient),
      ),
    );

    // Controls the contents fade animations
    final contentsFadeAnimationController = useAnimationController(duration: anims.terminalFadeTransitionDuration);
    // Runs the contents fade forward whenever there is a new value for the `contents` property
    useEffect(() {
      contentsFadeAnimationController.forward();
      return () => contentsFadeAnimationController.dispose;
    }, [contents]);

    // Controls both fade and move animations for the terminal actions
    final actionsAnimationController = useAnimationController(duration: anims.terminalActionsTransitionDuration);

    final contentsStack = Stack(
      children: [
        Positioned.fill(child: _buildAnimatableQuillReadOnlyEditor(context, contentsFadeAnimationController)),
        Positioned(top: 0, left: 0, right: 0, child: terminalHeader),
        Positioned(bottom: 0, left: 0, right: 0, child: terminalActionTransition),
        _buildAnimatablePositionedTerminalActions(actionsAnimationController),
      ],
    );

    final buttonDivider = Container(height: dimens.executionsTerminalBorderWidth, color: borderColor);

    final actionText = isDisplayingQuestion ? strings.executionCheckAnswer : strings.executionNext;
    final actionButton = TextButton(
      style: TextButton.styleFrom(primary: theme.primarySwatch.shade300),
      onPressed: onActionTapped != null
          ? () => _animateActionTapped(
                contentsController: contentsFadeAnimationController,
                actionsController: actionsAnimationController,
              )
          : null,
      child: Text(actionText.toUpperCase()),
    );

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: contentsStack),
          buttonDivider,
          actionButton.withSymmetricalPadding(context, vertical: Spacing.small),
        ],
      ),
    ).withAllPadding(context, Spacing.xSmall);
  }

  Future<void> _animateActionTapped({
    required AnimationController contentsController,
    required AnimationController actionsController,
  }) async {
    // If there is any animation going on, we ignore this action tap
    if (contentsController.isAnimating || actionsController.isAnimating) {
      return;
    }

    await Future.wait([
      // Before triggering the callback, we want to reverse the contents (due to the fade)
      contentsController.reverse(),
      // And if there is a question being displayed, we want the actions to be shown, otherwise hidden
      if (isDisplayingQuestion) actionsController.forward() else actionsController.reverse(),
    ]);
    onActionTapped!.call();
  }

  /// Builds a [_TerminalActions] that animates its position and fade given the [controller]
  AnimatedBuilder _buildAnimatablePositionedTerminalActions(AnimationController controller) {
    final curvedController = controller.drive(CurveTween(curve: anims.defaultAnimationCurve));

    return AnimatedBuilder(
      animation: curvedController,
      builder: (context, child) => Positioned(
        bottom: (curvedController.value * 100) - 100,
        left: 0,
        right: 0,
        child: Opacity(
          opacity: curvedController.value,
          child: _TerminalActions(
            onDifficultyMarked: onDifficultyMarked,
            markedAnswer: markedAnswer,
          ),
        ),
      ),
    );
  }

  /// Builds an animated quill editor that uses a [FadeTransition] to animate its contents
  Widget _buildAnimatableQuillReadOnlyEditor(BuildContext context, AnimationController controller) {
    final quillDocument = quill_doc.Document.fromJson(_headerFormattedToQuill + contents);

    final quillController = QuillController(
      document: quillDocument,
      selection: const TextSelection.collapsed(offset: 0),
    );

    final quillEditor = QuillEditor(
      controller: quillController,
      focusNode: FocusNode(),
      scrollController: ScrollController(),
      scrollable: true,
      padding: EdgeInsets.symmetric(
        vertical: dimens.executionsTerminalFadeHeight,
        horizontal: context.rawSpacing(Spacing.medium),
      ),
      autoFocus: false,
      readOnly: true,
      expands: false,
    );

    return FadeTransition(
      opacity: controller.drive(CurveTween(curve: anims.defaultAnimationCurve)),
      child: quillEditor,
    );
  }
}

class _TerminalHeader extends StatelessWidget {
  const _TerminalHeader({required this.fadeGradient, required this.borderColor});

  final Color borderColor;
  final List<Color> fadeGradient;
  static const _actionsAmount = 3;

  @override
  Widget build(BuildContext context) {
    final pseudoActions = List.generate(
      _actionsAmount,
      (index) => Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor),
        height: dimens.executionsTerminalActionDiameter,
        width: dimens.executionsTerminalActionDiameter,
      ),
    );

    return Container(
      height: dimens.executionsTerminalFadeHeight,
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

class _TerminalActions extends HookWidget {
  const _TerminalActions({required this.onDifficultyMarked, this.markedAnswer});

  final MemoDifficulty? markedAnswer;
  final void Function(MemoDifficulty difficulty) onDifficultyMarked;

  @override
  Widget build(BuildContext context) {
    final difficultyActions = MemoDifficulty.values.map((difficulty) {
      return GestureDetector(
        onTap: () => onDifficultyMarked(difficulty),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDifficultyAction(difficulty),
              context.verticalBox(Spacing.xSmall),
              Expanded(child: Text(strings.memoDifficulty(difficulty))),
            ],
          ),
        ),
      );
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: difficultyActions,
    ).withOnlyPadding(context, bottom: Spacing.xLarge);
  }

  Widget _buildDifficultyAction(MemoDifficulty difficulty) {
    final theme = useTheme();

    final blurFilter = BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: dimens.executionsTerminalBlur,
        sigmaY: dimens.executionsTerminalBlur,
      ),
      child: Container(color: Colors.transparent),
    );

    final difficultyEmoji = Text(
      strings.memoDifficultyEmoji(difficulty),
      style: const TextStyle(fontSize: dimens.executionsTerminalActionEmojiTextSize),
    );

    final highlightDecoration = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
          color: Colors.white,
          width: dimens.executionsTerminalBorderWidth,
        ),
      ),
    );

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(shape: BoxShape.circle, color: theme.neutralSwatch.shade400.withOpacity(0.1)),
      width: dimens.executionsTerminalActionSize,
      height: dimens.executionsTerminalActionSize,
      child: Stack(
        children: [
          Positioned.fill(child: blurFilter),
          Align(child: difficultyEmoji),
          if (markedAnswer == difficulty) Positioned.fill(child: highlightDecoration),
        ],
      ),
    );
  }
}
