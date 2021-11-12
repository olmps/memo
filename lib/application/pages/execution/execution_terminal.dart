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
import 'package:memo/application/view-models/execution/collection_execution_vm.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';

/// Coordinates the state (and animations) of a [ExecutionTerminal] widget.
class TerminalController extends ChangeNotifier {
  TerminalController({
    required MemoMetadata initialMemo,
    required this.onDifficultyMarked,
    required this.collectionName,
    required TickerProvider vsync,
  })  : _memo = initialMemo,
        editorAnimationController =
            AnimationController(vsync: vsync, value: 1, duration: anims.terminalAnimationDuration),
        editorScrollController = ScrollController(),
        actionsAnimationController = AnimationController(vsync: vsync, duration: anims.terminalAnimationDuration);

  // Controls fade animation for the editor contents.
  final AnimationController editorAnimationController;
  // Scroll controller for the editor contents.
  final ScrollController editorScrollController;

  // Controls both fade and move animations for the actions.
  final AnimationController actionsAnimationController;

  /// Callback that is called once a difficulty has been marked.
  ///
  /// The returned [MemoMetadata] will take place as the new memo, having its question being displayed at first.
  final Future<MemoMetadata?> Function(MemoDifficulty difficulty) onDifficultyMarked;

  /// Title for the terminal's contents, represented by the owner collection name.
  final String collectionName;

  /// Marked difficulty for the current memo.
  ///
  /// It becomes a non-null value only a brief period after [markDifficulty] has been called, so that the listener can
  /// visually show which difficulty has been marked, before starting to show the next memo, returned in
  /// [onDifficultyMarked].
  MemoDifficulty? get markedDifficulty => _markedDifficulty;

  /// `true` if the current contents being displayed are a [MemoMetadata.question], otherwise a [MemoMetadata.answer].
  bool get isDisplayingQuestion => _isDisplayingQuestion;

  /// Raw representation for the current question or answer (depending on [isDisplayingQuestion]).
  RawMemoContents get rawContents {
    final headerContents = <dynamic>[
      {
        'insert': '# $collectionName\n\n',
      },
      {
        'insert': '## ${isDisplayingQuestion ? strings.executionQuestion : strings.executionAnswer}\n',
      },
    ];
    final contents = isDisplayingQuestion ? _memo.question : _memo.answer;

    return List.from(headerContents + contents);
  }

  /// Current memo being displayed.
  MemoMetadata _memo;

  /// Controls whether the current [_memo] has its question or answer being displayed.
  bool _isDisplayingQuestion = true;

  /// Controls the difficulty marked for the current memo.
  ///
  /// See also: [markedDifficulty].
  MemoDifficulty? _markedDifficulty;

  bool get _isAcceptingActions =>
      !editorAnimationController.isAnimating && !actionsAnimationController.isAnimating && _markedDifficulty == null;

  /// Switches (animating the elements) to the current memo's answer/question.
  ///
  /// If there is an ongoing animation, the event is ignored.
  Future<void> switchContents() async {
    if (!_isAcceptingActions) {
      return;
    }

    await _animateElements();
  }

  /// Marks the current memo with the following [difficulty].
  ///
  /// Just like [switchContents], this animates all elements to conform a "difficulty-selection" behavior. This behavior
  /// is described by the following steps:
  /// 1. Updates the current [_markedDifficulty] and notify all listeners - read more in [markedDifficulty].
  /// 2. Requests the next memo by calling [onDifficultyMarked].
  /// 3. Calls the same animations as [switchContents].
  ///
  /// If the next requested memo returns `null`, does nothing other than the first step.
  Future<void> markDifficulty(MemoDifficulty difficulty) async {
    if (isDisplayingQuestion || !_isAcceptingActions) {
      return;
    }

    _markedDifficulty = difficulty;
    notifyListeners();

    final newMemo = await onDifficultyMarked(difficulty);
    // Delays the next animation so that the animation can be visible for a brief moment.
    await Future<void>.delayed(anims.terminalAnimationDuration);

    if (newMemo != null) {
      _memo = newMemo;
      await _animateElements();
    }
  }

  Future<void> _animateElements() async {
    await Future.wait([
      // Reverse the editor animation (to fade out its contents).
      editorAnimationController.reverse(),
      // ... and make sure that the editor scroll goes to the top.
      editorScrollController.animateTo(0,
          duration: anims.terminalAnimationDuration, curve: anims.defaultAnimationCurve),
      // Respectively hide/show the actions depending on the `isDisplayingQuestion`.
      if (isDisplayingQuestion) actionsAnimationController.forward() else actionsAnimationController.reverse(),
    ]);

    // Now that the editor text is faded out, we can update the state and notify the listeners, so they can adjust its
    // contents given the next expected state.
    _isDisplayingQuestion = !isDisplayingQuestion;
    _markedDifficulty = null;
    notifyListeners();

    // Then, animates the editor fade in.
    await editorAnimationController.forward();
  }

  @override
  void dispose() {
    editorAnimationController.dispose();
    editorScrollController.dispose();
    actionsAnimationController.dispose();

    super.dispose();
  }
}

/// Displays a series of chainable memo's question/answer, with actionable buttons to evalute its recall difficulty.
///
/// The lifecycle of this terminal is strictly controlled by a [TerminalController], so be careful when rebuilding this
/// widget.
///
/// The naming comes from its layout resemblance of most terminal applications.
class ExecutionTerminal extends StatefulHookWidget {
  const ExecutionTerminal({required this.controller, Key? key}) : super(key: key);

  final TerminalController controller;

  @override
  State<StatefulWidget> createState() => _ExecutionTerminalState();
}

class _ExecutionTerminalState extends State<ExecutionTerminal> {
  TerminalController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    useListenable(controller);

    final theme = useTheme();
    final borderColor = theme.neutralSwatch.shade700;
    final fadeGradient = [theme.neutralSwatch.shade900, theme.neutralSwatch.shade900.withOpacity(0)];

    final actionBackgroundColor = theme.neutralSwatch.shade400.withOpacity(0.1);
    final highlightColor = theme.secondarySwatch.shade400;

    // Build all widgets for `_TerminalContentsLayout`

    final header = _TerminalHeader(fadeGradient: fadeGradient, borderColor: borderColor);

    final editor = _TerminalQuillEditor(
      document: quill_doc.Document.fromJson(controller.rawContents),
      animationController: controller.editorAnimationController,
      scrollController: controller.editorScrollController,
    );
    // Bottom fade transition that resembles the `editor` end.
    final bottomFadeTransition = IgnorePointer(
      child: Container(
        height: dimens.executionsTerminalFadeHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: fadeGradient),
        ),
      ),
    );
    final actions = _TerminalActions(
      markedAnswer: controller.markedDifficulty,
      onDifficultyMarked: controller.markDifficulty,
      controller: controller.actionsAnimationController,
      actionBackgroundColor: actionBackgroundColor,
      highlightColor: highlightColor,
    );

    // Build the widgets for `TerminalWindow`

    final contentsLayout = _TerminalContentsLayout(
      header: header,
      editor: editor,
      bottomFadeTransition: bottomFadeTransition,
      actions: actions,
      isDisplayingQuestion: controller.isDisplayingQuestion,
    );

    final actionText = controller.isDisplayingQuestion ? strings.executionCheckAnswer : strings.executionCheckQuestion;
    final actionButton = CustomTextButton(text: actionText.toUpperCase(), onPressed: controller.switchContents);

    // Wraps it all under the `_TerminalWindow` root widget

    return _TerminalWindow(
      contents: contentsLayout,
      navigationButton: actionButton,
      borderColor: borderColor,
    ).withAllPadding(context, Spacing.xSmall);
  }
}

class _TerminalWindow extends StatelessWidget {
  const _TerminalWindow({required this.contents, required this.navigationButton, required this.borderColor});

  final _TerminalContentsLayout contents;
  final Widget navigationButton;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final buttonDivider = Container(height: dimens.executionsTerminalBorderWidth, color: borderColor);

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
          Expanded(child: ClipRect(child: contents)),
          buttonDivider,
          navigationButton.withSymmetricalPadding(context, vertical: Spacing.small),
        ],
      ),
    );
  }
}

enum _TerminalElements { header, editor, bottomFadeTransition, actions }

class _TerminalContentsLayout extends StatelessWidget {
  const _TerminalContentsLayout({
    required this.header,
    required this.editor,
    required this.bottomFadeTransition,
    required this.actions,
    required this.isDisplayingQuestion,
  });

  final Widget header;
  final Widget editor;
  final Widget bottomFadeTransition;
  final Widget actions;

  final bool isDisplayingQuestion;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _TerminalContentsLayoutDelegate(isActionsVisible: !isDisplayingQuestion),
      children: <Widget>[
        LayoutId(id: _TerminalElements.editor, child: editor),
        LayoutId(id: _TerminalElements.header, child: header),
        LayoutId(id: _TerminalElements.bottomFadeTransition, child: bottomFadeTransition),
        LayoutId(id: _TerminalElements.actions, child: actions),
      ],
    );
  }
}

class _TerminalContentsLayoutDelegate extends MultiChildLayoutDelegate {
  _TerminalContentsLayoutDelegate({required this.isActionsVisible});

  final bool isActionsVisible;

  @override
  void performLayout(Size size) {
    final looseConstraints = BoxConstraints.loose(size);

    layoutChild(_TerminalElements.header, looseConstraints);

    final bottomFadeTransition = layoutChild(_TerminalElements.bottomFadeTransition, looseConstraints);
    final actionsSize = layoutChild(_TerminalElements.actions, looseConstraints);

    // If actions are visible, we must subtract its size so contents won't overlap.
    final editorHeight = size.height - (isActionsVisible ? actionsSize.height : 0);
    final editor = layoutChild(
      _TerminalElements.editor,
      BoxConstraints.tightFor(height: editorHeight, width: size.width),
    );

    // No need to position header and editor because they are placed in `MultiChildLayoutDelegate` default offset (0,0).
    positionChild(_TerminalElements.bottomFadeTransition, Offset(0, editor.height - bottomFadeTransition.height));

    // We have also to adjust the actions y offset so it won't get clipped if any animation occurs.
    final actionsOffset = Offset(0, editor.height - (isActionsVisible ? 0 : actionsSize.height));
    positionChild(_TerminalElements.actions, actionsOffset);
  }

  @override
  bool shouldRelayout(_TerminalContentsLayoutDelegate oldDelegate) => oldDelegate.isActionsVisible != isActionsVisible;
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
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: fadeGradient)),
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

/// Builds an animated `flutter_quill` editor that uses a [FadeTransition] to animate its contents.
///
/// The editor is used in read-only mode.
class _TerminalQuillEditor extends StatelessWidget {
  const _TerminalQuillEditor({
    required this.document,
    required this.animationController,
    required this.scrollController,
  });

  final quill_doc.Document document;
  final AnimationController animationController;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    final quillEditor = QuillEditor(
      controller: quillController,
      focusNode: FocusNode(),
      scrollController: scrollController,
      scrollable: true,
      padding: EdgeInsets.symmetric(
        vertical: dimens.executionsTerminalFadeHeight,
        horizontal: context.rawSpacing(Spacing.medium),
      ),
      autoFocus: false,
      showCursor: false,
      readOnly: true,
      expands: false,
      enableInteractiveSelection: false,
    );

    return FadeTransition(
      opacity: animationController.drive(CurveTween(curve: anims.defaultAnimationCurve)),
      child: quillEditor,
    );
  }
}

class _TerminalActions extends HookWidget {
  const _TerminalActions({
    required this.onDifficultyMarked,
    required this.controller,
    required this.actionBackgroundColor,
    required this.highlightColor,
    this.markedAnswer,
  });

  final MemoDifficulty? markedAnswer;
  final void Function(MemoDifficulty difficulty) onDifficultyMarked;

  final AnimationController controller;

  final Color actionBackgroundColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final difficultyActions = MemoDifficulty.values.map((difficulty) {
      final isMarkedAnswer = difficulty == markedAnswer;

      final difficultyEmoji = Text(
        strings.memoDifficultyEmoji(difficulty),
        style: const TextStyle(fontSize: dimens.executionsTerminalActionEmojiTextSize),
      );

      return GestureDetector(
        onTap: () => onDifficultyMarked(difficulty),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDifficultyAction(isMarkedAnswer, difficultyEmoji, highlightColor, actionBackgroundColor),
              context.verticalBox(Spacing.xSmall),
              Expanded(
                child: Text(
                  strings.memoDifficulty(difficulty),
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: isMarkedAnswer ? highlightColor : null),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    final terminalActions = Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: difficultyActions);
    return _wrapInAnimationBuilder(terminalActions).withOnlyPadding(context, bottom: Spacing.xLarge);
  }

  /// Wraps a [widget] that animates its position and fade given the [controller].
  Widget _wrapInAnimationBuilder(Widget widget) {
    final curvedController = controller.drive(CurveTween(curve: anims.defaultAnimationCurve));

    return AnimatedBuilder(
      animation: curvedController,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -(curvedController.value * 100) + 100),
        child: Opacity(
          opacity: curvedController.value,
          child: widget,
        ),
      ),
    );
  }

  Widget _buildDifficultyAction(
      bool isMarkedAnswer, Text difficultyEmoji, Color highlightColor, Color actionBackgroundColor) {
    final hasMarkedAnswer = markedAnswer != null;

    final blurFilter = BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: dimens.executionsTerminalBlur,
        sigmaY: dimens.executionsTerminalBlur,
      ),
      child: Container(color: Colors.transparent),
    );

    final highlightDecoration = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
          color: highlightColor,
          width: dimens.executionsTerminalBorderWidth * 2,
        ),
      ),
    );

    return Opacity(
      opacity: hasMarkedAnswer && !isMarkedAnswer ? 0.4 : 1,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(shape: BoxShape.circle, color: actionBackgroundColor),
        width: dimens.executionsTerminalActionSize,
        height: dimens.executionsTerminalActionSize,
        child: Stack(
          children: [
            Positioned.fill(child: blurFilter),
            Align(child: difficultyEmoji),
            if (isMarkedAnswer) Positioned.fill(child: highlightDecoration),
          ],
        ),
      ),
    );
  }
}
