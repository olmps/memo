import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/material/asset_icon_button.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';
import 'package:memo/application/widgets/theme/themed_container.dart';
import 'package:mocktail/mocktail.dart';

import '../../../utils/widget_pump.dart';

class MockCallbackFunction extends Mock {
  void call();
}

void main() {
  group('Height Constraints - ', () {
    testWidgets('should respect the minimum constrained height', (tester) async {
      const richTextField = RichTextField(modalTitle: Text('any'), placeholder: 'any');
      final expectedHeight = dimens.richTextFieldConstraints.minHeight;

      await pumpThemedProviderScoped(tester, richTextField);

      final renderedField = find.byType(RichTextField).first.evaluate().single.renderObject! as RenderBox;
      expect(renderedField.size.height, expectedHeight);
    });

    testWidgets('should respect the maximum constrained height', (tester) async {
      const hugeFakeText = r'A\nHuge\nFake\nText\nThat\nWill\nExpand\nThe\nRich\nText\nEditor';
      const encodedText = '[{"insert":"$hugeFakeText\\n"}]';
      final controller = TextEditingController(text: encodedText);
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);
      final expectedHeight = dimens.richTextFieldConstraints.maxHeight;

      await pumpThemedProviderScoped(tester, richTextField);

      final renderedField = find.byType(RichTextField).first.evaluate().single.renderObject! as RenderBox;
      expect(renderedField.size.height, expectedHeight);
    });
  });

  group('Editor Toolbar - ', () {
    testWidgets('should not present toolbar when the keyboard is not visible', (tester) async {
      final focusNode = FocusNode();
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', focus: focusNode);

      await pumpThemedProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      focusNode.unfocus();
      await tester.pumpAndSettle();

      final editorModalTitle = find.byType(ThemedBottomContainer);
      expect(editorModalTitle, findsNothing);
    });

    testWidgets('should present toolbar when the keyboard is visible', (tester) async {
      const richTextField = RichTextField(modalTitle: Text('any'), placeholder: 'any');

      await pumpThemedProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      final editorModalTitle = find.byType(ThemedBottomContainer);
      expect(editorModalTitle, findsOneWidget);
    });

    group('Attributes Icons - ', () {
      testWidgets('should highlight bold button when text is bolded', (tester) async {
        final highlightedColor = ThemeController().state.neutralSwatch.shade800;
        const boldedText = r'[{"insert":"Bold Text\n","attributes": {"bold": true}}]';
        final controller = TextEditingController(text: boldedText);
        final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);

        await pumpThemedProviderScoped(tester, richTextField);
        await tester.tap(find.byType(RichTextField));
        await tester.pumpAndSettle();

        final attributeIcons = find.byType(AssetIconButton);
        final boldButton = tester.widget(attributeIcons.first) as AssetIconButton;
        expect(boldButton.iconColor, highlightedColor);
      });

      testWidgets('should highlight italic button when text is italic', (tester) async {
        final highlightedColor = ThemeController().state.neutralSwatch.shade800;
        const italicText = r'[{"insert":"Italic Text\n","attributes": {"italic": true}}]';
        final controller = TextEditingController(text: italicText);
        final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);

        await pumpThemedProviderScoped(tester, richTextField);
        await tester.tap(find.byType(RichTextField));
        await tester.pumpAndSettle();

        final attributeIcons = find.byType(AssetIconButton);
        final italicIcon = tester.widget(attributeIcons.at(1)) as AssetIconButton;
        expect(italicIcon.iconColor, highlightedColor);
      });

      testWidgets('should highlight underline button when text is underline', (tester) async {
        final highlightedColor = ThemeController().state.neutralSwatch.shade800;
        const underlineText = r'[{"insert":"Underline Text\n","attributes": {"underline": true}}]';
        final controller = TextEditingController(text: underlineText);
        final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);

        await pumpThemedProviderScoped(tester, richTextField);
        await tester.tap(find.byType(RichTextField));
        await tester.pumpAndSettle();

        final attributeIcons = find.byType(AssetIconButton);
        final underlineIcon = tester.widget(attributeIcons.at(2)) as AssetIconButton;
        expect(underlineIcon.iconColor, highlightedColor);
      });

      testWidgets('should highlight code button when text is code', (tester) async {
        final highlightedColor = ThemeController().state.neutralSwatch.shade800;
        const codeText = r'[{"insert":"Code Text"},{"insert":"\n","attributes":{"code-block":true}}]';
        final controller = TextEditingController(text: codeText);
        final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);

        await pumpThemedProviderScoped(tester, richTextField);
        await tester.tap(find.byType(RichTextField));
        await tester.pumpAndSettle();

        final attributeIcons = find.byType(AssetIconButton);
        final codeIcon = tester.widget(attributeIcons.last) as AssetIconButton;
        expect(codeIcon.iconColor, highlightedColor);
      });
    });
  });

  group('Editor Text Attributes', () {
    testWidgets('should bold selected text when bold button is tapped', (tester) async {
      const codeText = 'A Random Text to be changed';
      const encodedText = '[{"insert":"$codeText\\n"}]';
      const textSelection = TextSelection(baseOffset: 0, extentOffset: codeText.length);
      final controller = TextEditingController.fromValue(
        const TextEditingValue(text: encodedText, selection: textSelection),
      );
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);
      const expectedEncodedBoldText = '[{"insert":"$codeText","attributes":{"bold":true}},{"insert":"\\n"}]';

      await pumpThemedProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      final boldButton = find.byType(AssetIconButton).first;
      await tester.tap(boldButton);
      await tester.pumpAndSettle();

      expect(controller.text, expectedEncodedBoldText);
    });

    testWidgets('should italic selected text when italic button is tapped', (tester) async {
      const codeText = 'A Random Text to be changed';
      const encodedText = '[{"insert":"$codeText\\n"}]';
      const textSelection = TextSelection(baseOffset: 0, extentOffset: codeText.length);
      final controller = TextEditingController.fromValue(
        const TextEditingValue(text: encodedText, selection: textSelection),
      );
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);
      const expectedEncodedItalicText = '[{"insert":"$codeText","attributes":{"italic":true}},{"insert":"\\n"}]';

      await pumpThemedProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      final italicButton = find.byType(AssetIconButton).at(1);
      await tester.tap(italicButton);
      await tester.pumpAndSettle();

      expect(controller.text, expectedEncodedItalicText);
    });

    testWidgets('should underline selected text when underline button is tapped', (tester) async {
      const codeText = 'A Random Text to be changed';
      const encodedText = '[{"insert":"$codeText\\n"}]';
      const textSelection = TextSelection(baseOffset: 0, extentOffset: codeText.length);
      final controller = TextEditingController.fromValue(
        const TextEditingValue(text: encodedText, selection: textSelection),
      );
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);
      const expectedEncodedUnderlineText = '[{"insert":"$codeText","attributes":{"underline":true}},{"insert":"\\n"}]';

      await pumpThemedProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      final underlineButton = find.byType(AssetIconButton).at(2);
      await tester.tap(underlineButton);
      await tester.pumpAndSettle();

      expect(controller.text, expectedEncodedUnderlineText);
    });

    testWidgets('should code selected text when code button is tapped', (tester) async {
      const codeText = 'A Random Text to be changed';
      const encodedText = '[{"insert":"$codeText\\n"}]';
      const textSelection = TextSelection.collapsed(offset: codeText.length);
      final controller = TextEditingController.fromValue(
        const TextEditingValue(text: encodedText, selection: textSelection),
      );
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);
      const expectedEncodedCodeText =
          r'[{"insert":"A Random Text to be changed"},{"insert":"\n","attributes":{"code-block":true}}]';

      await pumpThemedProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      final codeButton = find.byType(AssetIconButton).last;
      await tester.tap(codeButton);
      await tester.pumpAndSettle();

      expect(controller.text, expectedEncodedCodeText);
    });
  });
}
