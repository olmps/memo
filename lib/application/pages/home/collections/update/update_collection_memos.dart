import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/pages/home/collections/update/update_collection_metadata.dart';
import 'package:memo/application/pages/home/collections/update/update_memo_terminal.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/home/update_collection_memos_vm.dart';
import 'package:memo/application/view-models/home/update_collection_vm.dart';
import 'package:memo/application/widgets/material/asset_icon_button.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';

class UpdateCollectionMemos extends HookConsumerWidget {
  const UpdateCollectionMemos({required this.controller});

  final PageController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(updateCollectionMemosVM.notifier);
    final state = ref.watch(updateCollectionMemosVM);
    final currentPageIndex = useState(0);

    final parentVM = ref.watch(updateCollectionVM.notifier);
    ref.listen<UpdateMemosState>(updateCollectionMemosVM, (_, state) => parentVM.updateMemos(memos: state.memos));

    useEffect(
      () {
        void onPageUpdate() => currentPageIndex.value = controller.page!.toInt();

        controller.addListener(onPageUpdate);
        return () => controller.removeListener(onPageUpdate);
      },
      [],
    );

    // Uses `PageView.custom` to support pages reordering.
    final pagesView = PageView.custom(
      controller: controller,
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == state.memos.length) {
            return _CreateMemoEmptyState(onTap: vm.createEmptyMemo);
          }

          final metadata = state.memos[index];

          return _MemoPage(
            key: ValueKey(metadata),
            pageIndex: index,
            metadata: metadata,
            onUpdate: (memoMetadata) => vm.updateMemoAtIndex(index, metadata: memoMetadata),
            onRemove: state.memos.length > 1 ? () => vm.removeMemoAtIndex(index) : null,
          ).withOnlyPadding(context, right: Spacing.xSmall);
        },
        // Adds +1 to include creation empty state.
        childCount: state.memos.length + 1,
        // Returns the memo index in case of reordering.
        findChildIndexCallback: (key) {
          final valueKey = key as ValueKey<MemoUpdateMetadata>;
          return state.memos.indexOf(valueKey.value);
        },
      ),
    );

    void onPreviousTapped() =>
        controller.previousPage(duration: anims.pageControllerAnimationDuration, curve: anims.defaultAnimationCurve);
    void onNextTapped() =>
        controller.nextPage(duration: anims.pageControllerAnimationDuration, curve: anims.defaultAnimationCurve);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: pagesView),
        context.verticalBox(Spacing.large),
        _NavigationIndicator(
          // Adds +1 to transform index into page
          currentPage: currentPageIndex.value + 1,
          // Adds +1 to include the creation CTA
          pagesAmount: state.memos.length + 1,
          onLeftTapped: currentPageIndex.value > 0 ? onPreviousTapped : null,
          onRightTapped: currentPageIndex.value < state.memos.length ? onNextTapped : null,
        ),
      ],
    ).withSymmetricalPadding(context, vertical: Spacing.medium);
  }
}

/// Editable `Memo` [metadata] wrapped around an [UpdateMemoTerminal].
class _MemoPage extends HookConsumerWidget {
  const _MemoPage({
    required this.pageIndex,
    required this.metadata,
    required this.onUpdate,
    required this.onRemove,
    Key? key,
  }) : super(key: key);

  /// The index from current [_MemoPage] in the parent [PageView].
  final int pageIndex;

  final MemoUpdateMetadata metadata;

  /// Triggers when updating the `Memo` question or answer content.
  final void Function(MemoUpdateMetadata metadata) onUpdate;

  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionValue = mapMemoUpdateContentToRichTextValue(metadata.question);
    final questionController = RichTextFieldController.fromValue(questionValue);

    final answerValue = mapMemoUpdateContentToRichTextValue(metadata.answer);
    final answerController = RichTextFieldController.fromValue(answerValue);

    useEffect(
      () {
        void onQuestionUpdate() {
          final updatedContent = MemoUpdateContent(
            richContent: questionController.value.richText,
            plainContent: questionController.value.plainText,
          );

          onUpdate(metadata.copyWith(question: updatedContent));
        }

        void onAnswerUpdate() {
          final updatedContent = MemoUpdateContent(
            richContent: answerController.value.richText,
            plainContent: answerController.value.plainText,
          );

          onUpdate(metadata.copyWith(answer: updatedContent));
        }

        questionController.addListener(onQuestionUpdate);
        answerController.addListener(onAnswerUpdate);

        return () {
          questionController.removeListener(onQuestionUpdate);
          answerController.removeListener(onAnswerUpdate);
        };
      },
      [],
    );

    return UpdateMemoTerminal(
      memoIndex: pageIndex + 1,
      questionController: questionController,
      answerController: answerController,
      onRemove: onRemove,
    );
  }
}

/// Directional actions between all [_MemoPage] belonging to a horizontal [PageView].
class _NavigationIndicator extends StatelessWidget {
  const _NavigationIndicator({
    required this.currentPage,
    required this.pagesAmount,
    this.onLeftTapped,
    this.onRightTapped,
  });

  /// Displays the current [_MemoPage] index, in the parent [PageView].
  final int currentPage;

  /// Displays the total available [_MemoPage].
  final int pagesAmount;

  final VoidCallback? onLeftTapped;
  final VoidCallback? onRightTapped;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AssetIconButton(images.chevronLeftAsset, onPressed: onLeftTapped),
        Text('$currentPage/$pagesAmount', style: textTheme.subtitle2),
        AssetIconButton(images.chevronRightAsset, onPressed: onRightTapped),
      ],
    );
  }
}

/// An empty state call-to-action to add a new `Memo` to its `Collection`.
class _CreateMemoEmptyState extends ConsumerWidget {
  const _CreateMemoEmptyState({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final textTheme = Theme.of(context).textTheme;

    final createMemoCta = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(images.addCircleAsset, color: theme.primarySwatch.shade400),
        context.verticalBox(Spacing.small),
        Text(
          strings.newMemo.toUpperCase(),
          style: textTheme.button?.copyWith(color: theme.primarySwatch.shade400),
          textAlign: TextAlign.center,
        )
      ],
    );

    return Material(
      borderRadius: dimens.executionsTerminalBorderRadius,
      child: InkWell(
        borderRadius: dimens.executionsTerminalBorderRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: theme.neutralSwatch.shade700, width: dimens.genericBorderHeight),
            borderRadius: dimens.executionsTerminalBorderRadius,
            color: theme.neutralSwatch.shade800,
          ),
          child: Center(child: createMemoCta),
        ),
      ),
    );
  }
}
