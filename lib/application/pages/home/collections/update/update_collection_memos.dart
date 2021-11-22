import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/theme/theme_controller.dart';

class UpdateCollectionMemos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CreateMemoEmptyState(
      onTap: () {
        // TODO(ggirotto): Connect with the VM when available
      },
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
      child: InkWell(
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
