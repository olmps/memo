import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/layoutr.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/pages/home/collections/collections_list_view.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/home/collections_vm.dart';
import 'package:memo/application/widgets/theme/themed_tab_bar.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';

class CollectionsPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final initialState = context.read(collectionsVM.state);
    final collectionsTabController = useTabController(
      initialLength: availableSegments.length,
      initialIndex: initialState.segmentIndex,
    );

    useEffect(() {
      void tabListener() {
        final currentState = context.read(collectionsVM.state);

        // Mandatory check because this listener is called multiple times by the tab controller.
        //
        // Should only call the VM when the `indexIsChanging` AND if the current segment is different.
        if (collectionsTabController.indexIsChanging && currentState.segmentIndex != collectionsTabController.index) {
          final newTab = availableSegments.elementAt(collectionsTabController.index);
          context.read(collectionsVM).updateCollectionsSegment(newTab);
        }
      }

      collectionsTabController.addListener(tabListener);
      return () => collectionsTabController.removeListener(tabListener);
    }, [collectionsTabController]);

    final tabs = availableSegments.map(_widgetForTab).toList();
    return Column(
      children: [
        ThemedTabBar(controller: collectionsTabController, tabs: tabs),
        Expanded(
          child: _CollectionsContents(
            onSegmentSwapRequested: () {
              final nextIndex = (collectionsTabController.index + 1) % availableSegments.length;
              collectionsTabController.animateTo(nextIndex);
            },
          ),
        ),
      ],
    );
  }

  Widget _widgetForTab(CollectionsSegment segment) {
    final String text;
    switch (segment) {
      case CollectionsSegment.explore:
        text = strings.collectionsExploreTab;
        break;
      case CollectionsSegment.review:
        text = strings.collectionsReviewTab;
        break;
    }

    // Not using flutter's `Tab` widget as it implicitly adds a material's hard-coded height.
    return Text(text);
  }
}

/// [CollectionsPage] visible contents, given the current [collectionsVM] state.
class _CollectionsContents extends HookWidget {
  const _CollectionsContents({required this.onSegmentSwapRequested});

  /// {@macro onSegmentSwapRequested}
  final VoidCallback onSegmentSwapRequested;

  @override
  Widget build(BuildContext context) {
    final state = useProvider(collectionsVM.state);

    final Widget widget;
    if (state is LoadingCollectionsState) {
      widget = const Center(child: CircularProgressIndicator());
    } else if (state is LoadedCollectionsState) {
      final items = state.collectionItems;

      if (items.isEmpty) {
        widget = _CollectionsEmptyState(
          onSegmentSwapRequested: onSegmentSwapRequested,
          title: strings.collectionsEmptyTitleSegment(state.currentSegment),
          description: strings.collectionsEmptyMessageSegment(state.currentSegment),
        );
      } else {
        widget = CollectionsListView(items);
      }
    } else {
      throw InconsistentStateError.layout('Unsupported subtype (${state.runtimeType}) of `CollectionsState`');
    }

    return widget.withSymmetricalPadding(context, horizontal: Spacing.medium);
  }
}

class _CollectionsEmptyState extends HookWidget {
  const _CollectionsEmptyState({required this.onSegmentSwapRequested, required this.title, required this.description});

  /// {@template onSegmentSwapRequested}
  /// An empty-state request for a segment swap.
  /// {@endtemplate}
  final VoidCallback onSegmentSwapRequested;

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final theme = useTheme();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          images.folderBigAsset,
          height: dimens.collectionsEmptyStateSize,
          width: dimens.collectionsEmptyStateSize,
          fit: BoxFit.contain,
          color: theme.neutralSwatch.shade700,
        ),
        context.verticalBox(Spacing.xLarge),
        Text(title, style: textTheme.headline6, textAlign: TextAlign.center),
        context.verticalBox(Spacing.medium),
        Text(
          description,
          style: textTheme.bodyText2?.copyWith(color: theme.neutralSwatch.shade400),
          textAlign: TextAlign.center,
        ),
        context.verticalBox(Spacing.xLarge),
        ElevatedButton(
          onPressed: onSegmentSwapRequested,
          child: Text(strings.collectionsStartNow.toUpperCase(), style: textTheme.button),
        )
      ],
    ).withAllPadding(context, Spacing.large);
  }
}
