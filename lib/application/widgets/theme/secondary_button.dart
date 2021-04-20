import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memo/application/theme/theme_controller.dart';

/// Alternative [ElevatedButton], used in scenarios that has a different contrast than the primary (default) one
///
/// To style itself, this button not only needs to be a child of `MaterialApp`, but also be in a context where a
/// `ThemeController` is provided as well.
class SecondaryButton extends HookWidget {
  const SecondaryButton({required this.child, required this.onPressed, Key? key}) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: useTheme().neutralSwatch.shade800),
      onPressed: onPressed,
      child: child,
    );
  }
}
