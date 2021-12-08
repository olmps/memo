import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/pages/home/collections/update/update_memo_terminal.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/application/widgets/theme/destructive_button.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';
import 'package:mocktail/mocktail.dart';

import '../../../utils/mocks.dart';
import '../../../utils/widget_pump.dart';

void main() {
  testWidgets('should become scrollable when the content exceeds the available height', (tester) async {
    const hugeFakeText = r'A\nHuge\nFake\nText\nThat\nWill\nExpand\nThe\nRich\nText\nEditor';
    const encodedText = '[{"insert":"$hugeFakeText\\n"}]';
    final scrollController = ScrollController();
    final questionController = RichTextFieldController(richText: encodedText, plainText: hugeFakeText);
    final answerController = RichTextFieldController(richText: encodedText, plainText: hugeFakeText);

    // Wraps `MemoTerminal` in a tiny SizedBox to force its content to be scrollable
    final memoTerminal = SizedBox.square(
      dimension: 320,
      child: UpdateMemoTerminal(
        memoIndex: 0,
        questionController: questionController,
        answerController: answerController,
        scrollController: scrollController,
      ),
    );
    const dragOffset = 500.0;

    await pumpProviderScoped(tester, memoTerminal);
    await tester.drag(find.byType(UpdateMemoTerminal), const Offset(0, -dragOffset));
    await tester.pump();

    expect(scrollController.offset, greaterThan(0));
  });

  testWidgets('should present confirmation modal when the remove button is tapped', (tester) async {
    final onRemoveCallback = MockCallbackFunction();
    final memoTerminal = UpdateMemoTerminal(memoIndex: 0, onRemove: onRemoveCallback);

    await pumpProviderScoped(tester, memoTerminal);

    await tester.tap(find.byType(CustomTextButton));
    await tester.pumpAndSettle();

    final confirmationTitle = find.text(strings.removeMemoTitle);
    expect(confirmationTitle, findsOneWidget);
  });

  testWidgets('should trigger onRemove when confirming memo removal', (tester) async {
    final onRemoveCallback = MockCallbackFunction();
    final memoTerminal = UpdateMemoTerminal(memoIndex: 0, onRemove: onRemoveCallback);

    await pumpProviderScoped(tester, memoTerminal);

    await tester.tap(find.byType(CustomTextButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DestructiveButton));
    await tester.pumpAndSettle();

    verify(onRemoveCallback.call).called(1);
  });
}
