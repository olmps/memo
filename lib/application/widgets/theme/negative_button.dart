import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memo/application/theme/theme_controller.dart';

/// Negative alternative to [ElevatedButton].
///
/// Used in scenarios where the user action may be destructive
class NegativeButton extends HookWidget {
  const NegativeButton({required this.onPressed, required this.child, Key? key}) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: useTheme().negativeSwatch),
      onPressed: onPressed,
      child: child,
    );
  }
}
