import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/layoutr.dart';
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/pages/home/collections/collections_list_view.dart';
import 'package:memo/application/view-models/home/collections_vm.dart';
import 'package:memo/application/widgets/theme/themed_tab_bar.dart';

class CollectionsPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final initialState = context.read(collectionsVM.state);
    final collectionsTabController = useTabController(
      initialLength: availableSegments.length,
      initialIndex: initialState.segmentIndex,
    );
    final tabs = availableSegments.map(_widgetForTab).toList();

    // Adds listener once (in the first build call)
    useEffect(() {
      collectionsTabController.addListener(() {
        final currentState = context.read(collectionsVM.state);

        // We want to update only when the indexIsChanging (because this listener is called multiple times by the tab
        // controller) and if the current tab index is different from the index of the current segment, so they are
        // always in sync
        if (collectionsTabController.indexIsChanging && currentState.segmentIndex != collectionsTabController.index) {
          final newTab = availableSegments.elementAt(collectionsTabController.index);
          context.read(collectionsVM).updateCollectionsSegment(newTab);
        }
      });
    }, []);

    return Column(
      children: [
        ThemedTabBar(controller: collectionsTabController, tabs: tabs),
        Expanded(child: const CollectionsListView().withSymmetricalPadding(context, horizontal: Spacing.medium))
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

    // Not using `Tab` widget as it implicitly adds a material's hard-coded height
    return Text(text);
  }
}
