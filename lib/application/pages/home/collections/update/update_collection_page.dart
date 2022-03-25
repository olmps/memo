import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/pages/home/collections/update/update_collection_details.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_memos.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_metadata.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_providers.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/utils/bottom_sheet.dart';
import 'package:memo/application/view-models/home/update_collection_vm.dart';
import 'package:memo/application/widgets/material/asset_icon_button.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/application/widgets/theme/exception_retry_container.dart';
import 'package:memo/application/widgets/theme/themed_container.dart';
import 'package:memo/application/widgets/theme/themed_tab_bar.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';

enum _Segment { details, memos }

class UpdateCollectionPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSegment = useState(_Segment.details);
    final tabController = useTabController(initialLength: _Segment.values.length);
    final memosPageController = usePageController(viewportFraction: dimens.memosPageControllerViewportFraction);

    useEffect(
      () {
        void tabListener() => selectedSegment.value = _Segment.values[tabController.index];

        tabController.addListener(tabListener);
        return () => tabController.removeListener(tabListener);
      },
      [],
    );

    final tabs = _Segment.values.map((segment) => Text(segment.title)).toList();

    return Scaffold(
      appBar: _AppBar(selectedSegment: selectedSegment.value, memosPageController: memosPageController),
      body: Column(
        children: [
          ThemedTabBar(controller: tabController, tabs: tabs),
          Expanded(
            child: _UpdateCollectionContents(
              selectedSegment: selectedSegment.value,
              memosPageController: memosPageController,
            ),
          ),
          _BottomActionContainer(
            onSegmentSwapRequested: (segment) => tabController.animateTo(_Segment.values.indexOf(segment)),
            selectedSegment: selectedSegment.value,
          ),
        ],
      ),
    );
  }
}

class _AppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _AppBar({required this.selectedSegment, required this.memosPageController});

  final _Segment selectedSegment;
  final PageController memosPageController;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(updateCollectionVM.notifier);
    final state = ref.watch(updateCollectionVM);
    final title = vm.isEditing ? strings.editCollection : strings.newCollection;

    void onPressed(int questionIndex) {
      // Dismiss the navigation bottom sheet
      Navigator.of(context).pop();

      // Navigates to chosen question index
      memosPageController.animateToPage(
        questionIndex,
        duration: anims.pageControllerAnimationDuration,
        curve: anims.defaultAnimationCurve,
      );
    }

    return AppBar(
      title: Text(title),
      actions: [
        if (state is UpdateCollectionLoaded && selectedSegment == _Segment.memos)
          AssetIconButton(
            images.organizeAsset,
            onPressed: () => showSnappableDraggableModalBottomSheet<void>(
              context,
              child: _MemosReorderableList(
                memos: state.memosMetadata,
                currentMemoIndex: memosPageController.hasClients ? memosPageController.page!.toInt() : 0,
                onReorder: vm.swapMemoIndex,
                onPressed: onPressed,
              ),
            ),
          )
      ],
    );
  }
}

class _UpdateCollectionContents extends ConsumerWidget {
  const _UpdateCollectionContents({required this.selectedSegment, required this.memosPageController});

  final _Segment selectedSegment;
  final PageController memosPageController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(updateCollectionVM.notifier);
    final state = ref.watch(updateCollectionVM);

    if (state is UpdateCollectionFailedLoading) {
      return Center(child: ExceptionRetryContainer(exception: state.exception, onRetry: vm.loadContent));
    }

    if (state is UpdateCollectionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UpdateCollectionLoaded) {
      switch (selectedSegment) {
        case _Segment.details:
          return ProviderScope(
            key: Key(_Segment.details.title),
            overrides: [
              updateDetailsMetadata.overrideWithValue(state.collectionMetadata),
            ],
            child: UpdateCollectionDetails(),
          );

        case _Segment.memos:
          return ProviderScope(
            key: Key(_Segment.memos.title),
            overrides: [
              updateMemosMetadata.overrideWithValue(state.memosMetadata),
            ],
            child: UpdateCollectionMemos(controller: memosPageController),
          );
      }
    }

    throw InconsistentStateError.layout('Unsupported subtype (${state.runtimeType}) of `UpdateCollectionState`');
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
    final theme = ref.watch(themeController);

    final Widget button;

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
    final vm = ref.watch(updateCollectionVM.notifier);
    final state = ref.watch(updateCollectionVM);

    if (state is! UpdateCollectionLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    void onPressed() => state.hasMemos ? vm.saveCollection : onSegmentSwapRequested(_Segment.memos);
    final buttonTitle = state.hasMemos ? strings.saveCollection : strings.next;
    return PrimaryElevatedButton(onPressed: state.hasValidDetails ? onPressed : null, text: buttonTitle.toUpperCase());
  }
}

class _MemosActionButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(updateCollectionVM.notifier);
    final state = ref.watch(updateCollectionVM);

    if (state is! UpdateCollectionLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return PrimaryElevatedButton(
      onPressed: state.canSaveCollection ? vm.saveCollection : null,
      text: strings.saveCollection.toUpperCase(),
    );
  }
}

class _MemosReorderableList extends ConsumerWidget {
  const _MemosReorderableList({
    required this.memos,
    required this.currentMemoIndex,
    required this.onReorder,
    required this.onPressed,
  });

  final List<MemoUpdateMetadata> memos;

  /// Selected index of [memos].
  ///
  /// Indicates which memo is currently highlighted.
  final int currentMemoIndex;

  /// Called when a memo is moved from `oldIndex` to `newIndex`.
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Called when a memo at `index` is pressed.
  final void Function(int index) onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final listHeader = Text('${strings.jumpTo}...', style: textTheme.subtitle1, textAlign: TextAlign.center);

    return Theme(
      // Overrides theme to remove canvasColor and shadowColor when dragging a Memo card
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent, shadowColor: Colors.transparent),
      child: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        header: listHeader.withSymmetricalPadding(context, vertical: Spacing.medium),
        itemCount: memos.length,
        onReorder: (oldIndex, newIndex) {
          // `ReorderableListView` bug. Waiting for a fix in https://github.com/flutter/flutter/issues/24786.
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          onReorder(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final memoMetadata = memos[index];

          return _MemosReorderableListRow(
            // Child from `ReorderableListView` must have associated keys in the root Widget.
            key: ValueKey(memoMetadata.id),
            index: index,
            metadata: memoMetadata,
            onTap: () => onPressed.call(index),
            isHighlighted: index == currentMemoIndex,
          );
        },
      ),
    );
  }
}

class _MemosReorderableListRow extends ConsumerWidget {
  const _MemosReorderableListRow({
    required this.index,
    required this.metadata,
    required this.onTap,
    this.isHighlighted = false,
    Key? key,
  }) : super(key: key);

  /// Index from current `Memo` in the memos list of a collection.
  final int index;

  final MemoUpdateMetadata metadata;
  final VoidCallback onTap;

  /// If `true` style the current row to differentiate from the others.
  final bool isHighlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final textTheme = Theme.of(context).textTheme;

    final memoContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.updateMemoQuestionTitle(index + 1),
          style: textTheme.bodyText1?.copyWith(color: theme.secondarySwatch),
        ),
        context.verticalBox(Spacing.xSmall),
        Text(metadata.question.plainContent, maxLines: 3),
      ],
    );

    return Material(
      child: InkWell(
        borderRadius: dimens.genericRoundedElementBorderRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: dimens.genericRoundedElementBorderRadius,
            color: isHighlighted ? theme.neutralSwatch.shade700 : theme.neutralSwatch.shade800,
          ),
          child: Row(
            children: [
              Expanded(child: memoContent),
              ReorderableDragStartListener(index: index, child: Image.asset(images.dragAsset)),
            ],
          ).withSymmetricalPadding(context, vertical: Spacing.small, horizontal: Spacing.medium),
        ),
      ).withSymmetricalPadding(context, vertical: Spacing.xSmall, horizontal: Spacing.medium),
    );
  }
}
