import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:layoutr/common_layout.dart';

import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/coordinator/routes_coordinator.dart';
import 'package:memo/application/pages/execution/completed_execution_contents.dart';
import 'package:memo/application/pages/execution/execution_providers.dart';
import 'package:memo/application/pages/execution/execution_terminal.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/execution/collection_execution_vm.dart';
import 'package:memo/application/widgets/animatable_progress.dart';
import 'package:memo/application/widgets/material/asset_icon_button.dart';

class CollectionExecutionPage extends StatefulHookWidget {
  @override
  State<StatefulWidget> createState() => _CollectionExecutionPageState();
}

class _CollectionExecutionPageState extends State<CollectionExecutionPage> {
  @override
  Widget build(BuildContext context) {
    final state = useCollectionExecutionState();

    if (state is LoadedCollectionExecutionState) {
      final allowsActionTap = state.isDisplayingQuestion || state.markedAnswer != null;
      return Scaffold(
        appBar: _ExecutionAppBar(state.completionValue),
        body: ExecutionTerminal(
          contents: state.currentContents,
          isDisplayingQuestion: state.isDisplayingQuestion,
          collectionName: state.collectionName,
          markedAnswer: state.markedAnswer,
          onDifficultyMarked: readExecutionVM(context).markCurrentMemoDifficulty,
          onActionTapped: allowsActionTap ? readExecutionVM(context).nextContents : null,
        ),
      );
    }

    if (state is FinishedCollectionExecutionState) {
      return Scaffold(
        appBar: const _ExecutionAppBar(null),
        body: CompletedExecutionContents(state, onBackTap: readCoordinator(context).navigateToStudy),
      );
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ExecutionAppBar extends HookWidget implements PreferredSizeWidget {
  const _ExecutionAppBar(this.completionValue);

  final double? completionValue;
  String? get semanticCompletionDescription =>
      completionValue != null ? (completionValue! * 100).round().toString() : null;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Widget? titleWidget;
    if (completionValue != null) {
      final actions = Row(
        children: [
          AssetIconButton(images.closeAsset, onPressed: () => _showCloseDialog(context)),
          Expanded(child: _buildCompletionProgress()),
        ],
      );

      titleWidget = PreferredSize(
        preferredSize: preferredSize,
        child: actions.withSymmetricalPadding(context),
      );
    }

    return AppBar(title: titleWidget, automaticallyImplyLeading: false);
  }

  Widget _buildCompletionProgress() {
    final memoTheme = useTheme();
    final lineColor = memoTheme.secondarySwatch.shade400;

    return AnimatableLinearProgress(
      value: completionValue!,
      animationCurve: anims.defaultAnimationCurve,
      animationDuration: anims.defaultAnimatableProgressDuration,
      lineSize: dimens.collectionsLinearProgressLineWidth,
      lineColor: lineColor,
      lineBackgroundColor: memoTheme.neutralSwatch.shade800,
      semanticLabel: strings.executionLinearIndicatorCompletionLabel(semanticCompletionDescription!),
    );
  }

  /// Displays an [AlertDialog] to reinforce the discard of the current execution
  Future<void> _showCloseDialog(BuildContext context) async {
    await showDialog<dynamic>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(strings.executionDiscardStudy),
          content: const Text(strings.executionDiscardStudyDescription),
          actions: [
            TextButton(
              // If yes is selected, we must discard the current displayed route, which will also dismiss this
              // uncontrolled dialog
              onPressed: readCoordinator(context).pop,
              child: Text(strings.yes.toUpperCase()),
            ),
            TextButton(
              // But if no is selected (and because this dialog is not added/controlled by our coordinator) we should
              // dismiss it by calling the Material's navigator, because this is considered an uncontrolled dialog
              onPressed: Navigator.of(context).pop,
              child: Text(strings.no.toUpperCase()),
            ),
          ],
        );
      },
    );
  }
}
