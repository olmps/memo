import 'package:flutter/material.dart';

/// Highlights the [highlighted] contents, case-insensitive matched against [text].
///
/// If [highlighted] is `null`, fallback to simply use [text] using [textStyle].
class HighlightableText extends StatelessWidget {
  const HighlightableText({required this.text, this.textStyle, this.highlighted, this.highlightedStyle});

  final String text;
  final TextStyle? textStyle;

  /// Text to be case-insensitive matched against [text].
  final String? highlighted;

  /// The style of [highlighted], if not `null`.
  final TextStyle? highlightedStyle;

  @override
  Widget build(BuildContext context) {
    if (highlighted == null || !text.toLowerCase().contains(highlighted!.toLowerCase())) {
      return Text(text, style: textStyle);
    }

    final highlightBeginIndex = text.toLowerCase().indexOf(highlighted!.toLowerCase());
    final highlightEndIndex = highlightBeginIndex + highlighted!.length;

    final beforeHighlight = text.substring(0, highlightBeginIndex);
    final highlightText = text.substring(highlightBeginIndex, highlightEndIndex);
    final afterHighlight = text.substring(highlightEndIndex);

    return Text.rich(
      TextSpan(
        children: [
          if (beforeHighlight.isNotEmpty) TextSpan(text: beforeHighlight, style: textStyle),
          TextSpan(text: highlightText, style: highlightedStyle),
          if (afterHighlight.isNotEmpty) TextSpan(text: afterHighlight, style: textStyle),
        ],
      ),
    );
  }
}
