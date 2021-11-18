import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/animations.dart' as anims;
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/home/update_collection_memos_vm.dart';
import 'package:memo/application/view-models/home/update_collection_vm.dart';
import 'package:memo/application/widgets/material/asset_icon_button.dart';
import 'package:memo/application/widgets/theme/memo_terminal.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';

class UpdateCollectionMemos extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(updateCollectionMemosVM.notifier);
    final state = ref.watch(updateCollectionMemosVM);

    final controller = usePageController(viewportFraction: 0.95);
    final page = useState(0);

    useEffect(() {
      void onPageUpdate() => page.value = controller.page!.toInt();

      controller.addListener(onPageUpdate);
      return () => controller.removeListener(onPageUpdate);
    });

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
            onRemove: state.memos.length > 1 ? () => vm.removeMemoAtIndex(index) : null,
          ).withOnlyPadding(context, right: Spacing.xSmall);
        },
        // Adds +1 to include creation empty state.
        childCount: state.memos.length + 1,
        findChildIndexCallback: (key) {
          final valueKey = key as ValueKey<MemoMetadata>;
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
          currentMemoIndex: page.value,
          memosAmount: state.memos.length,
          onLeftTapped: page.value > 0 ? onPreviousTapped : null,
          onRightTapped: page.value < state.memos.length ? onNextTapped : null,
        ),
      ],
    ).withSymmetricalPadding(context, vertical: Spacing.medium);
  }
}

class _MemoPage extends HookConsumerWidget {
  const _MemoPage({required this.pageIndex, required this.metadata, this.onRemove, Key? key}) : super(key: key);

  final int pageIndex;
  final MemoMetadata metadata;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(updateCollectionMemosVM.notifier);
    final questionController = RichTextFieldController.fromValue(metadata.question);
    final answerController = RichTextFieldController.fromValue(metadata.answer);

    useEffect(() {
      void onQuestionUpdate() =>
          vm.updateMemoAtIndex(pageIndex, metadata: metadata.copyWith(question: questionController.value));
      void onAnswerUpdate() =>
          vm.updateMemoAtIndex(pageIndex, metadata: metadata.copyWith(answer: answerController.value));

      questionController.addListener(onQuestionUpdate);
      answerController.addListener(onAnswerUpdate);

      return () {
        questionController.removeListener(onQuestionUpdate);
        answerController.removeListener(onAnswerUpdate);
      };
    });

    return MemoTerminal(
      memoIndex: pageIndex + 1,
      questionController: questionController,
      answerController: answerController,
      onRemove: onRemove,
    );
  }
}

class _NavigationIndicator extends StatelessWidget {
  const _NavigationIndicator({
    required this.currentMemoIndex,
    required this.memosAmount,
    this.onLeftTapped,
    this.onRightTapped,
  });

  final int currentMemoIndex;
  final int memosAmount;

  final VoidCallback? onLeftTapped;
  final VoidCallback? onRightTapped;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AssetIconButton(images.chevronLeftAsset, onPressed: onLeftTapped),
        Text('$currentMemoIndex/$memosAmount', style: textTheme.subtitle2),
        AssetIconButton(images.chevronRightAsset, onPressed: onRightTapped),
      ],
    );
  }
}

/// An empty state CTA to add a new `Memo` to a `Collection`.
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
