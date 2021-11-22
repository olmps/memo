import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';

import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/coordinator/routes_coordinator.dart';
import 'package:memo/application/pages/execution/completed_execution_contents.dart';
import 'package:memo/application/pages/execution/execution_providers.dart';
import 'package:memo/application/pages/execution/execution_terminal.dart';
import 'package:memo/application/theme/memo_theme_data.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/utils/bottom_sheet.dart';
import 'package:memo/application/view-models/execution/collection_execution_vm.dart';
import 'package:memo/application/widgets/animatable_progress.dart';
import 'package:memo/application/widgets/material/asset_icon_button.dart';

class CollectionExecutionPage extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _CollectionExecutionPageState();
}

class _CollectionExecutionPageState extends ConsumerState<CollectionExecutionPage> with TickerProviderStateMixin {
  TerminalController? _terminalController;

  @override
  Widget build(BuildContext context) {
    final state = watchCollectionExecutionState(ref);

    if (state is LoadedCollectionExecutionState) {
      _terminalController ??= TerminalController(
        initialMemo: state.initialMemo,
        onDifficultyMarked: readExecutionVM(ref).markCurrentMemoDifficulty,
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
        body: CompletedExecutionContents(state, onBackTap: readCoordinator(ref).navigateToStudy),
      );
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ExecutionAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _ExecutionAppBar(this.completionValue);

  final double? completionValue;
  String? get semanticCompletionDescription =>
      completionValue != null ? (completionValue! * 100).round().toString() : null;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);

    Widget? titleWidget;
    if (completionValue != null) {
      final actions = Row(
        children: [
          AssetIconButton(images.closeAsset, onPressed: () => _showCloseSheet(context, ref)),
          Expanded(child: _buildCompletionProgress(theme)),
        ],
      );

      titleWidget = PreferredSize(
        preferredSize: preferredSize,
        child: actions.withSymmetricalPadding(context),
      );
    }

    return AppBar(title: titleWidget, automaticallyImplyLeading: false);
  }

  Widget _buildCompletionProgress(MemoThemeData theme) {
    final lineColor = theme.secondarySwatch.shade400;

    return AnimatableLinearProgress(
      value: completionValue!,
      animationCurve: anims.defaultAnimationCurve,
      animationDuration: anims.defaultAnimatableProgressDuration,
      lineSize: dimens.collectionsLinearProgressLineWidth,
      lineColor: lineColor,
      lineBackgroundColor: theme.neutralSwatch.shade800,
      semanticLabel: strings.executionLinearIndicatorCompletionLabel(semanticCompletionDescription!),
    );
  }

  /// Displays an bottom sheet alert to reinforce the discard of the current execution.
  Future<void> _showCloseSheet(BuildContext context, WidgetRef ref) => showDestructiveOperationModalBottomSheet(
        context,
        title: strings.executionDiscardStudy,
        message: strings.executionDiscardStudyDescription,
        destructiveActionTitle: strings.executionDiscard.toUpperCase(),
        cancelActionTitle: strings.executionBackToStudy.toUpperCase(),
        onDestructiveTapped: readCoordinator(ref).pop,
        onCancelTapped: Navigator.of(context).pop,
      );
}
