import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/widgets/theme/rich_text_field.dart';
import 'package:mocktail/mocktail.dart';

import '../../../utils/widget_pump.dart';

class MockCallbackFunction extends Mock {
  void call();
}

void main() {
  group('RichTextField - ', () {
    group('Height Constraints - ', () {
      testWidgets('should respect the minimum constrained height', (tester) async {
        const richTextField = RichTextField(title: Text('any'), placeholder: 'any');
        final expectedHeight = dimens.richTextFieldConstraints.minHeight;

        await pumpThemedProviderScoped(tester, richTextField);

        final renderedField = find.byType(RichTextField).first.evaluate().single.renderObject! as RenderBox;
        expect(renderedField.size.height, expectedHeight);
      });

      testWidgets('should respect the maximum constrained height', (tester) async {
        const hugeFakeText = 'A\nHuge\nFake\nText\nThat\nWill\nExpand\nThe\nRich\nText\nEditor';
        final controller = RichTextEditingController(initialText: hugeFakeText);
        final richTextField = RichTextField(title: const Text('any'), placeholder: 'any', controller: controller);
        final expectedHeight = dimens.richTextFieldConstraints.maxHeight;

        await pumpThemedProviderScoped(tester, richTextField);

        final renderedField = find.byType(RichTextField).first.evaluate().single.renderObject! as RenderBox;
        expect(renderedField.size.height, expectedHeight);
      });
    });

    group('Editor Modal - ', () {
      testWidgets('should present editor modal when tapped', (tester) async {
        const fakeTitle = 'Editor Title';
        const richTextField = RichTextField(title: Text(fakeTitle), placeholder: 'any');

        await pumpThemedProviderScoped(tester, richTextField);
        await tester.tap(find.byType(RichTextField));
        await tester.pumpAndSettle();

        final editorModalTitle = find.text(fakeTitle);
        expect(editorModalTitle, findsOneWidget);
      });
    });

    group('RichTextEditingController - ', () {
      testWidgets('should notify its listeners when the content is updated', (tester) async {
        final controller = RichTextEditingController();
        final fakeCallback = MockCallbackFunction();

        controller.addListener(fakeCallback);
        controller.update('any');

        verify(fakeCallback.call).called(1);
      });
    });
  });
}
