import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';

/// Destructive alternative to [ElevatedButton].
///
/// Used in scenarios that emphasizes an action with impactful consequences.
class DestructiveButton extends HookWidget {
  const DestructiveButton({required this.onPressed, required this.text, Key? key}) : super(key: key);

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PrimaryElevatedButton(
      backgroundColor: useTheme().destructiveSwatch,
      onPressed: onPressed,
      text: text,
    );
  }
}
