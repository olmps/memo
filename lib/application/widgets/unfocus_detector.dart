import 'package:flutter/material.dart';

/// A wrapper Widget that request unfocus when tapping outside [child].
class UnfocusDetector extends StatelessWidget {
  const UnfocusDetector({required this.child});

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
