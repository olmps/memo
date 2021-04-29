import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:layoutr/common_layout.dart';

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
    final customWidgets = Row(children: [
      AssetIconButton(images.closeAsset, onPressed: Navigator.of(context).pop),
      if (completionValue != null) Expanded(child: _buildCompletionProgress()),
    ]);

    return AppBar(
      bottom: PreferredSize(
        preferredSize: preferredSize,
        child: customWidgets.withSymmetricalPadding(context, horizontal: Spacing.medium),
      ),
    );
  }

  Widget _buildCompletionProgress() {
    final memoTheme = useTheme();
    final lineColor = memoTheme.secondarySwatch.shade400;

    return AnimatableLinearProgress(
      value: completionValue!,
      animationCurve: dimens.defaultAnimationCurve,
      animationDuration: dimens.defaultAnimatableProgressDuration,
      lineSize: dimens.collectionsLinearProgressLineWidth,
      lineColor: lineColor,
      lineBackgroundColor: memoTheme.neutralSwatch.shade800,
      semanticLabel: strings.executionLinearIndicatorCompletionLabel(semanticCompletionDescription!),
    );
  }
}
