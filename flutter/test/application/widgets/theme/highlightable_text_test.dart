import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/widgets/theme/highlightable_text.dart';

import '../../../utils/widget_pump.dart';

void main() {
  testWidgets('should use the default textStyle on anything other than the highlightable text', (tester) async {
    const expectedPrefixSpan = TextSpan(text: 'A ', style: fakeTextStyle);
    const expectedSuffixSpan = TextSpan(text: ' text', style: fakeTextStyle);

    final textSpan = await _pumpHighlightedText(tester);

    final innerTextSpan = textSpan.children!.first as TextSpan;
    expect(innerTextSpan.children!.first, expectedPrefixSpan);
    expect(innerTextSpan.children!.last, expectedSuffixSpan);
  });

  testWidgets('should use the highlightedStyle on highlighted text', (tester) async {
    const expectedHighlightSpan = TextSpan(text: 'fake', style: fakeHighlightStyle);

    final textSpan = await _pumpHighlightedText(tester);

    final innerTextSpan = textSpan.children!.first as TextSpan;
    expect(innerTextSpan.children![1], expectedHighlightSpan);
  });

  testWidgets('should not highlight when highlighted text is null', (tester) async {
    const highlightableText = HighlightableText(text: fakeText, textStyle: fakeTextStyle);
    const expectedUnhighlightedText = Text(fakeText, style: fakeTextStyle);

    await pumpProviderScoped(tester, highlightableText);

    final unhighlightedText = tester.widget(find.byType(Text)) as Text;
    expect(unhighlightedText.toString(), expectedUnhighlightedText.toString());
  });

  testWidgets('should not highlight when the highlighted text does not exists in original text', (tester) async {
    const fakeNonExistingText = 'Memo';
    const highlightableText = HighlightableText(
      text: fakeText,
      textStyle: fakeTextStyle,
      highlighted: fakeNonExistingText,
      highlightedStyle: fakeHighlightStyle,
    );
    const expectedUnhighlightedText = Text(fakeText, style: fakeTextStyle);

    await pumpProviderScoped(tester, highlightableText);

    final unhighlightedText = tester.widget(find.byType(Text)) as Text;
    expect(unhighlightedText.toString(), expectedUnhighlightedText.toString());
  });

  testWidgets('should not consider case sensitive in highlighted text', (tester) async {
    const fakeCaseSensitiveHighlight = 'fAkE';
    const expectedHighlightSpan = TextSpan(text: fakeHighlight, style: fakeHighlightStyle);

    final textSpan = await _pumpHighlightedText(tester, highlightedText: fakeCaseSensitiveHighlight);

    final innerTextSpan = textSpan.children!.first as TextSpan;
    expect(innerTextSpan.children![1], expectedHighlightSpan);
  });
}

const fakeText = 'A fake text';
const fakeTextStyle = TextStyle(color: Colors.white);
const fakeHighlight = 'fake';
const fakeHighlightStyle = TextStyle(color: Colors.red);

/// Pumps [HighlightableText] using [tester] and returns the resulting [RichText.text].
///
/// Uses [highlightedText] as the highlighted text. When not specified, [fakeHighlight] will be used.
Future<TextSpan> _pumpHighlightedText(WidgetTester tester, {String? highlightedText}) async {
  final highlightableText = HighlightableText(
    text: fakeText,
    textStyle: fakeTextStyle,
    highlighted: highlightedText ?? fakeHighlight,
    highlightedStyle: fakeHighlightStyle,
  );

  await pumpProviderScoped(tester, highlightableText);

  final richText = tester.widget(find.byType(RichText)) as RichText;
  return richText.text as TextSpan;
}
