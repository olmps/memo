import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:layoutr/layoutr.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/theme/theme_controller.dart';

/// A visually opinionated [TextField].
///
/// The visual structure of this application text fields doesn't follow the material's guidelines. Although creating
/// a custom [TextField] widget is not the ideal solution - since all [TextField] properties must be proxied through
/// this component -, it's the only solution that enables the UI customization level that this widget requires.
class CustomTextField extends StatefulHookWidget {
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

  /// Text that provides context about the [TextField] value, such as how the value must be formatted.
  ///
  /// If non-null, the text is displayed below the [TextField], in the same location as [errorText].
  /// If any [errorText] is present, [helperText] will be ignored.
  final String? helperText;

  /// Text that describes the input field.
  final String? labelText;

  /// Text that appears below the [TextField] indicating an error.
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

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController controller;
  late FocusNode focusNode;

  bool get _hasErrorText => widget.errorText != null;
  bool get _hasHelperText => widget.helperText != null;

  @override
  void initState() {
    controller = widget.controller ?? TextEditingController();
    focusNode = widget.focusNode ?? FocusNode();

    focusNode.addListener(rebuildWidget);
    controller.addListener(rebuildWidget);

    super.initState();
  }

  @override
  void dispose() {
    focusNode.removeListener(rebuildWidget);
    controller.removeListener(rebuildWidget);
    super.dispose();
  }

  void rebuildWidget() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final neutralSwatch = theme.neutralSwatch;
    final textTheme = Theme.of(context).textTheme;

    final textField = Container(
      decoration: BoxDecoration(
        border: _hasErrorText ? Border.all(color: theme.destructiveSwatch, width: dimens.genericBorderHeight) : null,
        borderRadius: dimens.genericRoundedElementBorderRadius,
      ),
      child: TextField(
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        controller: controller,
        focusNode: focusNode,
        enabled: widget.enabled,
        textAlign: widget.textAlign,
        style: textTheme.bodyText2,
        cursorColor: theme.secondarySwatch.shade400,
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: _labelStyle(context, textTheme, neutralSwatch),
          suffixIcon: _buildSuffixIcon(neutralSwatch),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textField,
        context.verticalBox(Spacing.xxxSmall),
        if (_hasErrorText || _hasHelperText)
          Text(
            _hasErrorText ? widget.errorText! : widget.helperText!,
            style: textTheme.caption?.copyWith(color: _hasErrorText ? theme.destructiveSwatch : neutralSwatch.shade400),
          ).withOnlyPadding(context, left: Spacing.small)
      ],
    );
  }

  Widget? _buildSuffixIcon(MaterialColor neutralSwatch) {
    final hasText = controller.text.isNotEmpty;

    if (hasText && focusNode.hasFocus && widget.showsClearIcon) {
      return IconButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Image.asset(images.clearAsset, color: neutralSwatch.shade400),
        onPressed: () {
          controller.clear();
          widget.onChanged?.call(null);
        },
      );
    } else {
      return widget.suffixIcon;
    }
  }

  TextStyle? _labelStyle(BuildContext context, TextTheme textTheme, MaterialColor neutralSwatch) {
    final hasText = controller.text.isNotEmpty;

    if (focusNode.hasFocus || hasText) {
      return textTheme.caption?.copyWith(color: neutralSwatch.shade300);
    } else {
      return textTheme.subtitle1;
    }
  }
}
