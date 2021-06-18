// We've evaluated a bunch of alternative libraries (rubber, sliding_up_panel, stopper) to handle content-snapping
// alongside all native features that a Modal bottom sheet has, but none of them were solid enough, they usually created
// much more noise in the overall Widget-tree structure.
//
// Nonetheless, there are a couple of problems with Flutter's native [DraggableScrollableSheet], which are problematic
// for us, but non-blocking. They are:
// - We can't specify snapping values, meaning that it will always only snap to its full height and will always dismiss
// at the exact half of its height;
// - Whenever we add any scrollable widgets inside this modal, whenever we reach the top of the respective scroll view,
// it doesn't pull together the sheet - meaning that the sheet must always be dismissed by pulling its header (any
// non-scrollable widget at the top) or tapping in the background (barrierDismissible). There is an alternative to it,
// which is adding a DraggableScrollableSheet inside the Modal, but we then lose the snapping behavior.
//
// Relevant issues:
// - https://github.com/flutter/flutter/issues/34111
// - https://github.com/flutter/flutter/issues/45009
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/theme_controller.dart';

extension BottomSheetExtension on BuildContext {
  /// Wraps a [showModalBottomSheet] behavior that snaps its content based on [child] size
  ///
  /// If [isDismissible] is `false`, all drag interactions are disabled and the caller must handle its dismissal, like
  /// some close button or any other action that will eventually dismiss this modal. Also, no dragIndicator is drawn,
  /// to corroborate with the no-dragging behavior.
  ///
  /// The [child] must have a size to fit whitin the SingleChildScrollView
  Future<T?> showDraggableScrollableModalBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    Color? backgroundColor,
    String? title,
    Widget? leadingWidget,
    Widget? trailingWidget,
  }) {
    final dragIndicator = Container(
      width: dimens.dragIndicatorWidth,
      height: dimens.dragIndicatorHeight,
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(dimens.bottomSheetDragIndicatorRadius)),
      ),
    ).withSymmetricalPadding(this, vertical: Spacing.small);

    final hasHeaderItems = leadingWidget != null || title != null || trailingWidget != null;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isDismissible) Center(child: dragIndicator),
        if (hasHeaderItems)
          Stack(
            alignment: Alignment.center,
            children: [
              if (leadingWidget != null) Align(alignment: Alignment.centerLeft, child: leadingWidget),
              if (title != null) Align(child: Text(title, style: Theme.of(this).textTheme.headline6)),
              if (trailingWidget != null) Align(alignment: Alignment.centerRight, child: trailingWidget),
            ],
          ).withSymmetricalPadding(this, vertical: Spacing.small, horizontal: Spacing.medium)
      ],
    );

    return showModalBottomSheet<T>(
      context: this,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
      builder: (context) {
        return _ModalBottomSheet(
          header: header,
          isDismissible: isDismissible,
          title: title,
          leadingWidget: leadingWidget,
          trailingWidget: trailingWidget,
          backgroundColor: backgroundColor,
          child: child,
        );
      },
    );
  }
}

class _ModalBottomSheet extends HookWidget {
  const _ModalBottomSheet({
    required this.child,
    required this.header,
    this.isDismissible = true,
    this.title,
    this.leadingWidget,
    this.trailingWidget,
    this.backgroundColor,
  });

  final Widget child;

  final Widget header;

  final String? title;

  final Widget? leadingWidget;

  final Widget? trailingWidget;

  final bool isDismissible;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: context.deviceHeight * 0.6,
        minHeight: dimens.minBottomSheetHeight,
      ),
      child: Container(
        color: backgroundColor ?? useTheme().neutralSwatch.shade900,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            Flexible(
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
