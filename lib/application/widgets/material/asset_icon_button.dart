import 'package:flutter/material.dart';
import 'package:layoutr/common_layout.dart';

const double _iconButtonDefaultSize = 24;

/// Creates a new [IconButton] using an [asset].
class AssetIconButton extends StatelessWidget {
  const AssetIconButton(
    this.asset, {
    this.iconColor,
    this.iconSize,
    this.onPressed,
    this.padding,
    Key? key,
  }) : super(key: key);

  final String asset;
  final Color? iconColor;
  final double? iconSize;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final imageAsset = AssetImage(asset);
    final icon = ImageIcon(imageAsset, color: iconColor);

    // Even though `ImageIcon` already uses the theme to specify the icon size, we must enforce this through the
    // `IconButton` constructor, otherwise it will be overridden by the default argument.
    final normalizedIconSize = iconSize ?? Theme.of(context).iconTheme.size ?? _iconButtonDefaultSize;
    final normalizedPadding = padding ?? context.allInsets(Spacing.medium);

    return IconButton(
      icon: icon,
      iconSize: normalizedIconSize,
      padding: normalizedPadding,
      onPressed: onPressed,
    );
  }
}
