import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/widgets/theme/highlightable_text.dart';

import '../../../utils/widget_pump.dart';

void main() {
  const fakeText = 'A fake text';
  const fakeTextStyle = TextStyle(color: Colors.white);
  const fakeHighlight = 'fake';
  const fakeHighlightStyle = TextStyle(color: Colors.red);

  testWidgets('should not style highlight prefix', (tester) async {
    const highlightableText = HighlightableText(
      text: fakeText,
      textStyle: fakeTextStyle,
      highlighted: fakeHighlight,
      highlightedStyle: fakeHighlightStyle,
    );
    const expectedPrefixSpan = TextSpan(text: 'A ', style: fakeTextStyle);

    await pumpThemedProviderScoped(tester, highlightableText);

    final richText = tester.widget(find.byType(RichText)) as RichText;
    final textSpan = richText.text as TextSpan;
    final innerTextSpan = textSpan.children!.first as TextSpan;
    expect(innerTextSpan.children!.first, expectedPrefixSpan);
  });

  testWidgets('should style highlight text', (tester) async {
    const highlightableText = HighlightableText(
      text: fakeText,
      textStyle: fakeTextStyle,
      highlighted: fakeHighlight,
      highlightedStyle: fakeHighlightStyle,
    );
    const expectedPrefixSpan = TextSpan(text: 'fake', style: fakeHighlightStyle);

    await pumpThemedProviderScoped(tester, highlightableText);

    final richText = tester.widget(find.byType(RichText)) as RichText;
    final textSpan = richText.text as TextSpan;
    final innerTextSpan = textSpan.children!.first as TextSpan;
    expect(innerTextSpan.children![1], expectedPrefixSpan);
  });

  testWidgets('should not style highlight suffix', (tester) async {
    const highlightableText = HighlightableText(
      text: fakeText,
      textStyle: fakeTextStyle,
      highlighted: fakeHighlight,
      highlightedStyle: fakeHighlightStyle,
    );
    const expectedPrefixSpan = TextSpan(text: ' text', style: fakeTextStyle);

    await pumpThemedProviderScoped(tester, highlightableText);

    final richText = tester.widget(find.byType(RichText)) as RichText;
    final textSpan = richText.text as TextSpan;
    final innerTextSpan = textSpan.children!.first as TextSpan;
    expect(innerTextSpan.children!.last, expectedPrefixSpan);
  });
}
