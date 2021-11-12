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
import 'package:memo/application/utils/bottom_sheet.dart';
import 'package:memo/application/view-models/execution/collection_execution_vm.dart';
import 'package:memo/application/widgets/animatable_progress.dart';
import 'package:memo/application/widgets/material/asset_icon_button.dart';
import 'package:memo/application/widgets/theme/destructive_button.dart';
import 'package:memo/application/widgets/theme/secondary_button.dart';

class CollectionExecutionPage extends StatefulHookWidget {
  @override
  State<StatefulWidget> createState() => _CollectionExecutionPageState();
}

class _CollectionExecutionPageState extends State<CollectionExecutionPage> with TickerProviderStateMixin {
  TerminalController? _terminalController;

  @override
  Widget build(BuildContext context) {
    final state = useCollectionExecutionState();

    if (state is LoadedCollectionExecutionState) {
      _terminalController ??= TerminalController(
        initialMemo: state.initialMemo,
        onDifficultyMarked: readExecutionVM(context).markCurrentMemoDifficulty,
        collectionName: state.collectionName,
        vsync: this,
      );

      return Scaffold(
        appBar: _ExecutionAppBar(state.completionValue),
        body: SafeArea(child: ExecutionTerminal(controller: _terminalController!)),
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
          AssetIconButton(images.closeAsset, onPressed: () => _showCloseSheet(context)),
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

  /// Displays an bottom sheet alert to reinforce the discard of the current execution.
  Future<void> _showCloseSheet(BuildContext context) async {
    final textTheme = Theme.of(context).textTheme;

    return showSnappableDraggableModalBottomSheet(
      context,
      isDismissible: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(strings.executionDiscardStudy, style: textTheme.subtitle1),
          context.verticalBox(Spacing.xLarge),
          Text(strings.executionDiscardStudyDescription, style: textTheme.bodyText1),
          context.verticalBox(Spacing.xxxLarge),
          DestructiveButton(
            onPressed: readCoordinator(context).pop,
            text: strings.executionDiscard.toUpperCase(),
          ),
          context.verticalBox(Spacing.medium),
          SecondaryButton(onPressed: Navigator.of(context).pop, child: Text(strings.executionBackToStudy.toUpperCase()))
        ],
      ).withAllPadding(context, Spacing.medium),
    );
  }
}
