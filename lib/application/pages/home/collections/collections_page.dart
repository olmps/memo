import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/layoutr.dart';
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
        Expanded(child: CollectionsContents()),
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
class CollectionsContents extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final state = useProvider(collectionsVM.state);

    final Widget widget;
    if (state is LoadingCollectionsState) {
      widget = const Center(child: CircularProgressIndicator());
    } else if (state is LoadedCollectionsState) {
      final items = state.collectionItems;

      if (items.isEmpty) {
        // Empty state for the current segment.
        widget = Center(
          child: Text(
            strings.collectionsEmptySegment(state.currentSegment),
            style: Theme.of(context).textTheme.subtitle1?.copyWith(color: useTheme().neutralSwatch.shade300),
            textAlign: TextAlign.center,
          ),
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
