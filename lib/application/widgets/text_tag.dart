import 'package:flutter/widgets.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;

/// Creates a new [Text] that resembles a tag
///
/// It's important to no confuse this tag-styled component with the material's `Chip`, which is used in more complex
/// - usually interactable - scenarios.
class TextTag extends StatelessWidget {
  const TextTag(
    this.text, {
    required this.backgroundColor,
    required this.padding,
    this.textStyle,
    Key? key,
  }) : super(key: key);

  final String text;
  final Color backgroundColor;
  final EdgeInsets padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: dimens.textTagBorderRadius,
      ),
      child: Text(text, style: textStyle),
    );
  }
}
