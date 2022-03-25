import 'package:flutter/material.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;

const double _iconButtonDefaultSize = 24;

/// Creates a new [IconButton] using an [asset].
class AssetIconButton extends StatelessWidget {
  const AssetIconButton(
    this.asset, {
    this.iconColor,
    this.iconBackgroundColor,
    this.iconSize,
    this.onPressed,
    this.padding,
    this.isSplashEffectEnabled = true,
    Key? key,
  }) : super(key: key);

  final String asset;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final double? iconSize;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;

  /// Toggles Material's splash effect.
  final bool isSplashEffectEnabled;

  @override
  Widget build(BuildContext context) {
    final imageAsset = AssetImage(asset);
    final icon = DecoratedBox(
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        borderRadius: dimens.genericRoundedElementBorderRadius,
      ),
      child: ImageIcon(imageAsset, color: iconColor),
    );

    // Even though `ImageIcon` already uses the theme to specify the icon size, we must enforce this through the
    // `IconButton` constructor, otherwise it will be overridden by the default argument.
    final normalizedIconSize = iconSize ?? Theme.of(context).iconTheme.size ?? _iconButtonDefaultSize;
    final normalizedPadding = padding ?? context.allInsets(Spacing.medium);

    return IconButton(
      splashColor: isSplashEffectEnabled ? Theme.of(context).splashColor : Colors.transparent,
      icon: icon,
      iconSize: normalizedIconSize,
      padding: normalizedPadding,
      onPressed: onPressed,
    );
  }
}
