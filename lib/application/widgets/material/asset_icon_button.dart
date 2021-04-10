import 'package:flutter/material.dart';

/// Creates a new [IconButton] instance using an [asset]
class AssetIconButton extends StatelessWidget {
  const AssetIconButton(this.asset, {this.iconColor, this.iconSize, this.onPressed, Key? key}) : super(key: key);

  final String asset;
  final Color? iconColor;
  final double? iconSize;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final imageAsset = AssetImage(asset);
    final icon = ImageIcon(imageAsset, color: iconColor);

    // Even though `ImageIcon` already uses the theme to specify the icon size, we must enforce this through the
    // `IconButton` instance, otherwise it will be overridden by the default argument
    final normalizedIconSize = iconSize ?? Theme.of(context).iconTheme.size;

    if (normalizedIconSize != null) {
      return IconButton(icon: icon, iconSize: normalizedIconSize, onPressed: onPressed);
    }

    return IconButton(icon: icon, onPressed: onPressed);
  }
}
