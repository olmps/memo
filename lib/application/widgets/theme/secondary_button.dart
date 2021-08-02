import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memo/application/theme/theme_controller.dart';

/// Secondary alternative to [ElevatedButton].
///
/// Used in scenarios that has a different contrast than the primary (default) one.
class SecondaryButton extends HookWidget {
  const SecondaryButton({required this.onPressed, required this.child, Key? key}) : super(key: key);

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
