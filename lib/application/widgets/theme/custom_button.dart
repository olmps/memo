import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/theme_controller.dart';

@visibleForTesting
enum ButtonState { normal, pressed, disabled }

/// A visually opinionated [ElevatedButton].
///
/// Visually similar to Material's [ElevatedButton] but with custom disable/pressing behaviors and text style.
class PrimaryElevatedButton extends HookWidget {
  const PrimaryElevatedButton({required this.text, this.backgroundColor, this.onPressed, this.leadingAsset});

  final String text;

  /// {@macro _CustomElevatedButton.backgroundColor}
  final MaterialColor? backgroundColor;
  final VoidCallback? onPressed;

  /// {@macro _CustomElevatedButton.leadingAsset}
  final String? leadingAsset;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final color = backgroundColor ?? theme.primarySwatch;

    Color backgroundColorBuilder(ButtonState state) {
      switch (state) {
        case ButtonState.normal:
          return color.shade400;
        case ButtonState.pressed:
          return color;
        case ButtonState.disabled:
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
class SecondaryElevatedButton extends HookWidget {
  const SecondaryElevatedButton({required this.text, this.backgroundColor, this.onPressed, this.leadingAsset});

  final String text;

  /// {@macro _CustomElevatedButton.backgroundColor}
  final MaterialColor? backgroundColor;
  final VoidCallback? onPressed;

  /// {@macro _CustomElevatedButton.leadingAsset}
  final String? leadingAsset;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final color = backgroundColor ?? theme.neutralSwatch;

    Color backgroundColorBuilder(ButtonState state) {
      switch (state) {
        case ButtonState.normal:
          return color.shade700;
        case ButtonState.pressed:
          return color.shade800;
        case ButtonState.disabled:
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
class CustomTextButton extends HookWidget {
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
  Widget build(BuildContext context) {
    final theme = useTheme();
    final buttonColorSwatch = color ?? theme.primarySwatch;
    final textTheme = Theme.of(context).textTheme.button!;

    Color? buttonColor(ButtonState state) {
      switch (state) {
        case ButtonState.normal:
          return buttonColorSwatch.shade300;
        case ButtonState.pressed:
          return buttonColorSwatch.shade400;
        case ButtonState.disabled:
          return buttonColorSwatch.shade400.withOpacity(0.4);
      }
    }

    Widget leadingAssetBuilder(ButtonState state) => Image.asset(leadingAsset!, color: buttonColor(state));

    return _CustomButton(
      text: text,
      leadingWidgetBuilder: leadingAsset != null ? leadingAssetBuilder : null,
      onPressed: onPressed,
      textStyleBuilder: (state) => textTheme.copyWith(color: buttonColor(state)),
    );
  }
}

/// Wraps a [CustomButton] following a similar style to [ElevatedButton].
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
  final Color Function(ButtonState state) backgroundColorBuilder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.button!;

    Widget leadingAssetBuilder(ButtonState state) => Image.asset(leadingAsset!, color: textTheme.color);

    return _CustomButton(
      text: text,
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
class _CustomButton extends HookWidget {
  const _CustomButton({
    required this.text,
    this.onPressed,
    this.isPressedOverlayEnabled = false,
    this.leadingWidgetBuilder,
    this.borderBuilder,
    this.backgroundColorBuilder,
    this.backgroundGradientBuilder,
    this.textStyleBuilder,
  });

  /// The button text.
  ///
  /// Its style may be customized by implementing [textStyleBuilder].
  final String text;

  final VoidCallback? onPressed;

  /// If `true` adds a overlay over the button when it's pressed.
  final bool isPressedOverlayEnabled;

  /// Builds the button leading widget based on the button `state`.
  final Widget Function(ButtonState state)? leadingWidgetBuilder;

  /// Builds the button border based on the button `state`.
  ///
  /// If `null` no border is added.
  final BoxBorder? Function(ButtonState state)? borderBuilder;

  /// Builds the button background color based on the button `state`.
  ///
  /// Will be overriden by [backgroundGradientBuilder] if implemented.
  /// If `null` no background color is added.
  final Color? Function(ButtonState state)? backgroundColorBuilder;

  /// Builds the button background gradient based on the button `state`.
  ///
  /// Overrides [backgroundColorBuilder] if both are implemented.
  /// If `null` no background gradient is added.
  final LinearGradient? Function(ButtonState state)? backgroundGradientBuilder;

  /// Builds the button [text] style based on the button `state`.
  ///
  /// If `null` the default text theme is used.
  final TextStyle? Function(ButtonState state)? textStyleBuilder;

  @override
  Widget build(BuildContext context) {
    final initialState = onPressed != null ? ButtonState.normal : ButtonState.disabled;
    final state = useState(initialState);

    useEffect(() {
      if (state.value != ButtonState.pressed) {
        state.value = onPressed != null ? ButtonState.normal : ButtonState.disabled;
      }
    });

    final rowWidgets = <Widget>[];

    if (leadingWidgetBuilder != null) {
      rowWidgets.addAll([
        leadingWidgetBuilder!(state.value),
        context.horizontalBox(Spacing.xSmall),
      ]);
    }

    rowWidgets.add(Text(text, style: textStyleBuilder?.call(state.value)));

    final buttonContent = InkWell(
      // Disables default splash/highlight animation
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onPressed,
      onHighlightChanged: (isPressed) => state.value = isPressed ? ButtonState.pressed : ButtonState.normal,
      child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: rowWidgets)),
    );

    return Semantics(
      button: true,
      enabled: state.value != ButtonState.disabled,
      child: Container(
        height: dimens.minButtonHeight,
        decoration: BoxDecoration(
          border: borderBuilder?.call(state.value),
          color: backgroundColorBuilder?.call(state.value),
          gradient: backgroundGradientBuilder?.call(state.value),
          borderRadius: dimens.genericRoundedElementBorderRadius,
        ),
        child: buttonContent,
      ),
    );
  }
}
