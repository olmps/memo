import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/theme_controller.dart';

enum _ButtonState { normal, pressed, disabled }

/// A visually opinionated [ElevatedButton].
///
/// Visually similar to Material's [ElevatedButton] but with custom disable/pressing behaviors and text style.
class PrimaryElevatedButton extends ConsumerWidget {
  const PrimaryElevatedButton({required this.text, this.backgroundColor, this.onPressed, this.leadingAsset});

  final String text;

  /// {@macro _CustomElevatedButton.backgroundColor}
  final MaterialColor? backgroundColor;
  final VoidCallback? onPressed;

  /// {@macro _CustomElevatedButton.leadingAsset}
  final String? leadingAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final color = backgroundColor ?? theme.primarySwatch;

    Color backgroundColorBuilder(_ButtonState state) {
      switch (state) {
        case _ButtonState.normal:
          return color.shade400;
        case _ButtonState.pressed:
          return color;
        case _ButtonState.disabled:
          return color.withOpacity(0.4);
      }
    }

    return _CustomElevatedButton(
      text: text,
      backgroundColorBuilder: backgroundColorBuilder,
      backgroundColor: backgroundColor,
      onPressed: onPressed,
      leadingAsset: leadingAsset,
    );
  }
}

/// A visually alternative to [PrimaryElevatedButton].
///
/// It shares the same pressing/disabled behaviors from [PrimaryElevatedButton] but with a different color scheme.
class SecondaryElevatedButton extends ConsumerWidget {
  const SecondaryElevatedButton({required this.text, this.backgroundColor, this.onPressed, this.leadingAsset});

  final String text;

  /// {@macro _CustomElevatedButton.backgroundColor}
  final MaterialColor? backgroundColor;
  final VoidCallback? onPressed;

  /// {@macro _CustomElevatedButton.leadingAsset}
  final String? leadingAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final color = backgroundColor ?? theme.neutralSwatch;

    Color backgroundColorBuilder(_ButtonState state) {
      switch (state) {
        case _ButtonState.normal:
          return color.shade700;
        case _ButtonState.pressed:
          return color.shade800;
        case _ButtonState.disabled:
          return color.shade800.withOpacity(0.4);
      }
    }

    return _CustomElevatedButton(
      text: text,
      backgroundColorBuilder: backgroundColorBuilder,
      backgroundColor: backgroundColor,
      onPressed: onPressed,
      leadingAsset: leadingAsset,
    );
  }
}

/// A visually opinionated custom [TextButton].
///
/// Visually similar to Material's [TextButton] but with custom disable/pressing behaviors and an optional
/// [leadingAsset].
class CustomTextButton extends ConsumerWidget {
  const CustomTextButton({required this.text, this.color, this.leadingAsset, this.onPressed});

  final String text;

  /// Optional leading asset.
  ///
  /// Its color will be overriden by [color] - or the theme primary swatch if `null`.
  final String? leadingAsset;
  final VoidCallback? onPressed;

  /// Button's color.
  ///
  /// Applies to all button content, including [leadingAsset] if set.
  final MaterialColor? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final buttonColorSwatch = color ?? theme.primarySwatch;
    final textTheme = Theme.of(context).textTheme.button!;

    Color? buttonColor(_ButtonState state) {
      switch (state) {
        case _ButtonState.normal:
          return buttonColorSwatch.shade300;
        case _ButtonState.pressed:
          return buttonColorSwatch.shade400;
        case _ButtonState.disabled:
          return buttonColorSwatch.shade400.withOpacity(0.4);
      }
    }

    Widget leadingAssetBuilder(_ButtonState state) => Image.asset(leadingAsset!, color: buttonColor(state));

    return _CustomButton(
      text: text,
      shrink: true,
      leadingWidgetBuilder: leadingAsset != null ? leadingAssetBuilder : null,
      onPressed: onPressed,
      textStyleBuilder: (state) => textTheme.copyWith(color: buttonColor(state)),
    );
  }
}

/// Wraps a [_CustomButton] following a similar style to [ElevatedButton].
///
/// Reused by custom buttons implementations.
/// See also:
///
///   * [PrimaryElevatedButton]
///   * [SecondaryElevatedButton]
class _CustomElevatedButton extends StatelessWidget {
  const _CustomElevatedButton({
    required this.text,
    required this.backgroundColorBuilder,
    this.backgroundColor,
    this.onPressed,
    this.leadingAsset,
  });

  final String text;

  /// {@template _CustomElevatedButton.backgroundColor}
  /// Button's background color swatch.
  /// {@endtemplate}
  final MaterialColor? backgroundColor;
  final VoidCallback? onPressed;

  /// {@template _CustomElevatedButton.leadingAsset}
  /// Optional leading asset.
  ///
  /// Its color will be overriden by the button `TextStyle`.
  /// {@endtemplate}
  final String? leadingAsset;

  /// Builds the button background color based on the button state.
  final Color Function(_ButtonState state) backgroundColorBuilder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.button!;

    Widget leadingAssetBuilder(_ButtonState state) => Image.asset(leadingAsset!, color: textTheme.color);

    return _CustomButton(
      text: text,
      shrink: false,
      onPressed: onPressed,
      isPressedOverlayEnabled: true,
      backgroundColorBuilder: backgroundColorBuilder,
      textStyleBuilder: (state) => textTheme,
      leadingWidgetBuilder: leadingAsset != null ? leadingAssetBuilder : null,
    );
  }
}

/// Shared visual style between all custom button's.
///
/// Provides a common and customizable button style that must be used by all custom buttons.
///
/// See also:
///
///   * [PrimaryElevatedButton] - The primary visually opinionated alternative to [ElevatedButton].
///   * [SecondaryElevatedButton] - The secondary visually opinionated alternative to [ElevatedButton].
///   * [CustomTextButton] - The visually opinionated alternative to [TextButton].
class _CustomButton extends StatefulWidget {
  const _CustomButton({
    required this.text,
    required this.shrink,
    this.onPressed,
    this.isPressedOverlayEnabled = false,
    this.leadingWidgetBuilder,
    this.backgroundColorBuilder,
    this.textStyleBuilder,
  });

  /// The button text.
  ///
  /// Its style may be customized by implementing [textStyleBuilder].
  final String text;

  /// `true` when it should shrink to its horizontal size.
  ///
  /// Setting `false` will make it expand to fill the parent's width.
  final bool shrink;

  final VoidCallback? onPressed;

  /// If `true` adds a overlay over the button when it's pressed.
  final bool isPressedOverlayEnabled;

  /// Builds the button leading widget based on the button `state`.
  final Widget Function(_ButtonState state)? leadingWidgetBuilder;

  /// Builds the button background color based on the button `state`.
  ///
  /// If `null` no background color is added.
  final Color? Function(_ButtonState state)? backgroundColorBuilder;

  /// Builds the button [text] style based on the button `state`.
  ///
  /// If `null` the default text theme is used.
  final TextStyle? Function(_ButtonState state)? textStyleBuilder;

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<_CustomButton> {
  late _ButtonState state;

  @override
  void initState() {
    state = widget.onPressed != null ? _ButtonState.normal : _ButtonState.disabled;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _CustomButton oldWidget) {
    if (widget.onPressed != oldWidget.onPressed) {
      setState(() {
        state = widget.onPressed != null ? _ButtonState.normal : _ButtonState.disabled;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final rowWidgets = <Widget>[];

    if (widget.leadingWidgetBuilder != null) {
      rowWidgets.addAll([
        widget.leadingWidgetBuilder!(state),
        context.horizontalBox(Spacing.xSmall),
      ]);
    }

    rowWidgets.add(Text(widget.text, style: widget.textStyleBuilder?.call(state)));

    final buttonContent = InkWell(
      // Disables default splash/highlight animation
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: widget.onPressed,
      onHighlightChanged: (isPressed) => setState(() {
        state = isPressed ? _ButtonState.pressed : _ButtonState.normal;
      }),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: widget.shrink ? MainAxisSize.min : MainAxisSize.max,
        children: rowWidgets,
      ),
    );

    return Semantics(
      button: true,
      enabled: state != _ButtonState.disabled,
      child: Container(
        height: widget.shrink ? null : dimens.minButtonHeight,
        decoration: BoxDecoration(
          color: widget.backgroundColorBuilder?.call(state),
          borderRadius: dimens.genericRoundedElementBorderRadius,
        ),
        child: buttonContent,
      ),
    );
  }
}
