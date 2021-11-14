import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/pages/home/collections/update/update_collection_details.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_memos.dart';
import 'package:memo/application/pages/home/collections/update/update_providers.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/home/update_collection_vm.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/application/widgets/theme/exception_retry_container.dart';
import 'package:memo/application/widgets/theme/themed_container.dart';
import 'package:memo/application/widgets/theme/themed_tab_bar.dart';

enum _Segment { details, memos }

class UpdateCollectionPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = useUpdateCollectionVM(ref);

    final selectedSegment = useState(_Segment.details);
    final tabController = useTabController(initialLength: _Segment.values.length);

    useEffect(() {
      void tabListener() => selectedSegment.value = _Segment.values[tabController.index];

      tabController.addListener(tabListener);
      return () => tabController.removeListener(tabListener);
    });

    final tabs = _Segment.values.map((segment) => Text(segment.title)).toList();
    final title = vm.isEditing ? strings.editCollection : strings.newCollection;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          ThemedTabBar(controller: tabController, tabs: tabs),
          Expanded(child: _UpdateCollectionContents(selectedSegment: selectedSegment.value)),
          context.verticalBox(Spacing.large),
          _BottomActionContainer(
            onSegmentSwapRequested: (segment) => tabController.animateTo(_Segment.values.indexOf(segment)),
            selectedSegment: selectedSegment.value,
          ),
        ],
      ),
    );
  }
}

class _UpdateCollectionContents extends ConsumerWidget {
  const _UpdateCollectionContents({required this.selectedSegment});

  final _Segment selectedSegment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = useUpdateCollectionVM(ref);
    final state = useUpdateCollectionState(ref);

    if (state is UpdateCollectionFailedLoading) {
      return Center(child: ExceptionRetryContainer(exception: state.exception, onRetry: vm.loadInitialContent));
    }

    switch (selectedSegment) {
      case _Segment.details:
        return UpdateCollectionDetails();
      case _Segment.memos:
        return UpdateCollectionMemos();
    }
  }
}

extension on _Segment {
  String get title {
    switch (this) {
      case _Segment.details:
        return strings.details;
      case _Segment.memos:
        return strings.memos;
    }
  }
}

class _BottomActionContainer extends ConsumerWidget {
  const _BottomActionContainer({required this.selectedSegment, required this.onSegmentSwapRequested});

  final _Segment selectedSegment;
  final void Function(_Segment segment) onSegmentSwapRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = useTheme(ref);

    late Widget button;

    switch (selectedSegment) {
      case _Segment.details:
        button = _DetailsActionButton(onSegmentSwapRequested: onSegmentSwapRequested);
        break;
      case _Segment.memos:
        button = _MemosActionButton();
        break;
    }

    return ThemedBottomContainer(
      child: Container(
        color: theme.neutralSwatch.shade800,
        child: SafeArea(
          child: button.withSymmetricalPadding(context, vertical: Spacing.small, horizontal: Spacing.medium),
        ),
      ),
    );
  }
}

class _DetailsActionButton extends ConsumerWidget {
  const _DetailsActionButton({required this.onSegmentSwapRequested});

  final Function(_Segment segment) onSegmentSwapRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = useUpdateCollectionState(ref);

    if (state is! UpdateCollectionLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final vm = useUpdateCollectionVM(ref);

    void onPressed() {
      if (state.hasMemos) {
        vm.saveCollection();
      } else {
        onSegmentSwapRequested(_Segment.memos);
      }
    }

    final buttonTitle = state.hasMemos ? strings.saveCollection : strings.next;

    return PrimaryElevatedButton(onPressed: state.hasDetails ? onPressed : null, text: buttonTitle.toUpperCase());
  }
}

class _MemosActionButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = useUpdateCollectionState(ref);

    if (state is! UpdateCollectionLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final vm = useUpdateCollectionVM(ref);
    final canSave = state.hasDetails && state.hasMemos;

    return PrimaryElevatedButton(
      onPressed: canSave ? vm.saveCollection : null,
      text: strings.saveCollection.toUpperCase(),
    );
  }
}
