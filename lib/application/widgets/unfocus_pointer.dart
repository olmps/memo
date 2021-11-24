import 'package:flutter/material.dart';

/// A wrapper Widget that request unfocus when tapping non-interactable Widgets of [child].
///
/// The interaction with focusable Widgets from [child] will not be affected. The unfocus is only request when
/// interacting with non-focusable Widgets, such as [Container]s, [Column]s, etc.
class UnfocusPointer extends StatelessWidget {
  const UnfocusPointer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: child,
    );
  }
}
