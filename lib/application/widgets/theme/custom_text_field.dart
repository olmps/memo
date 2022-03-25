import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/layoutr.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/theme/theme_controller.dart';

/// A visually opinionated [TextField].
///
/// The visual structure of this application text fields doesn't follow the material's guidelines. Although creating
/// a custom [TextField] widget is not the ideal solution - since all [TextField] properties must be proxied through
/// this component -, it's the only solution that enables the UI customization level that this widget requires.
class CustomTextField extends HookConsumerWidget {
  const CustomTextField({
    this.enabled = true,
    this.helperText,
    this.labelText,
    this.errorText,
    this.controller,
    this.suffixIcon,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters = const [],
    this.onChanged,
    this.showsClearIcon = true,
    this.textAlign = TextAlign.start,
  });

  /// Ignores interactions if set to `false`.
  final bool enabled;

  /// {@template CustomTextField.helperText}
  /// Text that provides context about the [TextField] value, such as how the value must be formatted.
  ///
  /// If non-null, the text is displayed below the [TextField], in the same location as [errorText].
  /// If any [errorText] is present, [helperText] will be ignored.
  /// {@endtemplate}
  final String? helperText;

  /// Text that describes the input field.
  final String? labelText;

  /// {@template CustomTextField.errorText}
  /// Text that appears below the [TextField] indicating an error.
  /// {@endtemplate}
  final String? errorText;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// See [InputDecoration.suffixIcon].
  ///
  /// The [suffixIcon] is only used if the text is empty or [showsClearIcon] is `false`.
  final Widget? suffixIcon;

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  /// Defines the type of content of the field.
  ///
  /// It impacts directly in the keyboard that will be shown to the user. As an example, if [keyboardType] is
  /// [TextInputType.number], the keyboard will only contain numbers, as [TextInputType.emailAddress] will layout the
  /// keyboard to be more friendly when typing an email address.
  final TextInputType? keyboardType;

  /// Defines the formatters that will change the content on every update.
  final List<TextInputFormatter> inputFormatters;

  /// Called when the the current [TextEditingController] text changes.
  ///
  /// `value` may be `null` if the content was cleared.
  final Function(String? value)? onChanged;

  /// Shows a clear icon when the current [TextEditingController] text is not empty.
  ///
  /// Defaults to `true`.
  final bool showsClearIcon;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign textAlign;

  bool get _hasErrorText => errorText != null;
  bool get _hasHelperText => helperText != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeController);
    final neutralSwatch = theme.neutralSwatch;
    final textTheme = Theme.of(context).textTheme;

    final controller = this.controller ?? useTextEditingController();
    final focusNode = this.focusNode ?? useFocusNode();
    final hasFocus = useState(focusNode.hasFocus);
    final hasText = useState(controller.text.isNotEmpty);

    useEffect(() {
      void focusUpdate() {
        hasFocus.value = focusNode.hasFocus;
        hasText.value = controller.text.isNotEmpty;
      }

      controller.addListener(focusUpdate);
      focusNode.addListener(focusUpdate);

      return () {
        controller.removeListener(focusUpdate);
        focusNode.removeListener(focusUpdate);
      };
    });

    final labelStyle = hasFocus.value || hasText.value
        ? textTheme.caption?.copyWith(color: neutralSwatch.shade300)
        : textTheme.subtitle1;

    final textField = DecoratedBox(
      decoration: BoxDecoration(
        color: _hasErrorText ? theme.destructiveSwatch : null,
        borderRadius: dimens.genericRoundedElementBorderRadius,
      ),
      child: TextField(
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        textAlign: textAlign,
        style: textTheme.bodyText2,
        cursorColor: theme.secondarySwatch.shade400,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: labelStyle,
          suffixIcon: _buildSuffixIcon(
            hasFocus: hasFocus.value,
            hasText: hasText.value,
            neutralSwatch: theme.neutralSwatch,
            onTap: controller.clear,
          ),
        ),
      ).withAllPadding(context, Spacing.xxxSmall),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textField,
        context.verticalBox(Spacing.xxxSmall),
        if (_hasErrorText || _hasHelperText)
          Text(
            _hasErrorText ? errorText! : helperText!,
            style: textTheme.caption?.copyWith(color: _hasErrorText ? theme.destructiveSwatch : neutralSwatch.shade400),
          ).withOnlyPadding(context, left: Spacing.small)
      ],
    );
  }

  Widget? _buildSuffixIcon({
    required bool hasText,
    required bool hasFocus,
    required MaterialColor neutralSwatch,
    required VoidCallback onTap,
  }) {
    if (hasText && hasFocus && showsClearIcon) {
      return IconButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Image.asset(images.clearAsset, color: neutralSwatch.shade400),
        onPressed: () {
          onTap();
          onChanged?.call(null);
        },
      );
    } else {
      return suffixIcon;
    }
  }
}
