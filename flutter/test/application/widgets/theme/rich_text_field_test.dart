import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/constants/dimensions.dart' as dimens;
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/material/asset_icon_button.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';
import 'package:memo/application/widgets/theme/themed_container.dart';

import '../../../utils/widget_pump.dart';

void main() {
  group('Height Constraints - ', () {
    testWidgets('should respect the minimum constrained height', (tester) async {
      const richTextField = RichTextField(modalTitle: Text('any'), placeholder: 'any');
      final expectedHeight = dimens.richTextFieldConstraints.minHeight;

      await pumpProviderScoped(tester, richTextField);

      final renderedField = find.byType(RichTextField).first.evaluate().single.renderObject! as RenderBox;
      expect(renderedField.size.height, expectedHeight);
    });

    testWidgets('should respect the maximum constrained height', (tester) async {
      const hugeFakeText = r'A\nHuge\nFake\nText\nThat\nWill\nExpand\nThe\nRich\nText\nEditor';
      const encodedText = '[{"insert":"$hugeFakeText\\n"}]';
      final controller = RichTextFieldController(plainText: hugeFakeText, richText: encodedText);
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);
      final expectedHeight = dimens.richTextFieldConstraints.maxHeight;

      await pumpProviderScoped(tester, richTextField);

      final renderedField = find.byType(RichTextField).first.evaluate().single.renderObject! as RenderBox;
      expect(renderedField.size.height, expectedHeight);
    });
  });

  group('Editor Toolbar - ', () {
    testWidgets('should not present toolbar when the keyboard is not visible', (tester) async {
      final focusNode = FocusNode();
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', focus: focusNode);

      await pumpProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      focusNode.unfocus();
      await tester.pumpAndSettle();

      final editorModalTitle = find.byType(ThemedBottomContainer);
      expect(editorModalTitle, findsNothing);
    });

    testWidgets('should present toolbar when the keyboard is visible', (tester) async {
      const richTextField = RichTextField(modalTitle: Text('any'), placeholder: 'any');

      await pumpProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      final editorModalTitle = find.byType(ThemedBottomContainer);
      expect(editorModalTitle, findsOneWidget);
    });

    group('Attributes Icons - ', () {
      testWidgets('should highlight bold button when text is bolded', (tester) async {
        // ignore: invalid_use_of_protected_member
        final highlightedColor = ThemeController().state.neutralSwatch.shade800;
        const plainText = 'Bold Text';
        const encodedText = '[{"insert":"$plainText\\n","attributes": {"bold": true}}]';
        final controller = RichTextFieldController(plainText: plainText, richText: encodedText);
        final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);

        await pumpProviderScoped(tester, richTextField);
        await tester.tap(find.byType(RichTextField));
        await tester.pumpAndSettle();

        final attributeIcons = find.byType(AssetIconButton);
        final boldButton = tester.widget(attributeIcons.first) as AssetIconButton;
        expect(boldButton.iconColor, highlightedColor);
      });

      testWidgets('should highlight italic button when text is italic', (tester) async {
        // ignore: invalid_use_of_protected_member
        final highlightedColor = ThemeController().state.neutralSwatch.shade800;
        const plainText = 'Italic Text';
        const encodedText = '[{"insert":"$plainText\\n","attributes": {"italic": true}}]';
        final controller = RichTextFieldController(plainText: plainText, richText: encodedText);
        final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);

        await pumpProviderScoped(tester, richTextField);
        await tester.tap(find.byType(RichTextField));
        await tester.pumpAndSettle();

        final attributeIcons = find.byType(AssetIconButton);
        final italicIcon = tester.widget(attributeIcons.at(1)) as AssetIconButton;
        expect(italicIcon.iconColor, highlightedColor);
      });

      testWidgets('should highlight underline button when text is underline', (tester) async {
        // ignore: invalid_use_of_protected_member
        final highlightedColor = ThemeController().state.neutralSwatch.shade800;
        const plainText = 'Underline Text';
        const encodedText = '[{"insert":"$plainText\\n","attributes": {"underline": true}}]';
        final controller = RichTextFieldController(plainText: plainText, richText: encodedText);
        final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);

        await pumpProviderScoped(tester, richTextField);
        await tester.tap(find.byType(RichTextField));
        await tester.pumpAndSettle();

        final attributeIcons = find.byType(AssetIconButton);
        final underlineIcon = tester.widget(attributeIcons.at(2)) as AssetIconButton;
        expect(underlineIcon.iconColor, highlightedColor);
      });

      testWidgets('should highlight code button when text is code', (tester) async {
        // ignore: invalid_use_of_protected_member
        final highlightedColor = ThemeController().state.neutralSwatch.shade800;
        const plainText = 'Code Text';
        const encodedText = '[{"insert":"$plainText"},{"insert":"\\n","attributes":{"code-block":true}}]';
        final controller = RichTextFieldController(plainText: plainText, richText: encodedText);
        final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);

        await pumpProviderScoped(tester, richTextField);
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
      const plainText = 'A Random Text to be changed';
      const encodedText = '[{"insert":"$plainText\\n"}]';
      const textSelection = TextSelection(baseOffset: 0, extentOffset: plainText.length);
      final controller = RichTextFieldController(plainText: plainText, richText: encodedText, selection: textSelection);
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);
      const expectedEncodedBoldText = '[{"insert":"$plainText","attributes":{"bold":true}},{"insert":"\\n"}]';

      await pumpProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      final boldButton = find.byType(AssetIconButton).first;
      await tester.tap(boldButton);
      await tester.pumpAndSettle();

      expect(controller.richText, expectedEncodedBoldText);
    });

    testWidgets('should italic selected text when italic button is tapped', (tester) async {
      const plainText = 'A Random Text to be changed';
      const encodedText = '[{"insert":"$plainText\\n"}]';
      const textSelection = TextSelection(baseOffset: 0, extentOffset: plainText.length);
      final controller = RichTextFieldController(plainText: plainText, richText: encodedText, selection: textSelection);
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);
      const expectedEncodedItalicText = '[{"insert":"$plainText","attributes":{"italic":true}},{"insert":"\\n"}]';

      await pumpProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      final italicButton = find.byType(AssetIconButton).at(1);
      await tester.tap(italicButton);
      await tester.pumpAndSettle();

      expect(controller.richText, expectedEncodedItalicText);
    });

    testWidgets('should underline selected text when underline button is tapped', (tester) async {
      const plainText = 'A Random Text to be changed';
      const encodedText = '[{"insert":"$plainText\\n"}]';
      const textSelection = TextSelection(baseOffset: 0, extentOffset: plainText.length);
      final controller = RichTextFieldController(plainText: plainText, richText: encodedText, selection: textSelection);
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);
      const expectedEncodedUnderlineText = '[{"insert":"$plainText","attributes":{"underline":true}},{"insert":"\\n"}]';

      await pumpProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      final underlineButton = find.byType(AssetIconButton).at(2);
      await tester.tap(underlineButton);
      await tester.pumpAndSettle();

      expect(controller.richText, expectedEncodedUnderlineText);
    });

    testWidgets('should code selected text when code button is tapped', (tester) async {
      const plainText = 'A Random Text to be changed';
      const encodedText = '[{"insert":"$plainText\\n"}]';
      const textSelection = TextSelection.collapsed(offset: plainText.length);
      final controller = RichTextFieldController(plainText: plainText, richText: encodedText, selection: textSelection);
      final richTextField = RichTextField(modalTitle: const Text('any'), placeholder: 'any', controller: controller);
      const expectedEncodedCodeText = '[{"insert":"$plainText"},{"insert":"\\n","attributes":{"code-block":true}}]';

      await pumpProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      final codeButton = find.byType(AssetIconButton).last;
      await tester.tap(codeButton);
      await tester.pumpAndSettle();

      expect(controller.richText, expectedEncodedCodeText);
    });
  });

  group('Helper & Error Texts - ', () {
    testWidgets('should present helper text when provided', (tester) async {
      const fakeHelperText = 'Helper Text';
      const richTextField = RichTextField(modalTitle: Text('any'), placeholder: 'any', helperText: fakeHelperText);

      await pumpProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      expect(find.text(fakeHelperText), findsOneWidget);
    });

    testWidgets('error text should precede helper text', (tester) async {
      const fakeHelperText = 'Helper Text';
      const fakeErrorText = 'Error Text';
      const richTextField = RichTextField(
        modalTitle: Text('any'),
        placeholder: 'any',
        helperText: fakeHelperText,
        errorText: fakeErrorText,
      );

      await pumpProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      expect(find.text(fakeHelperText), findsNothing);
      expect(find.text(fakeErrorText), findsOneWidget);
    });

    testWidgets('should add error border when error text is not null', (tester) async {
      // ignore: invalid_use_of_protected_member
      final expectedColor = ThemeController().state.destructiveSwatch;
      const fakeErrorText = 'Error Text';
      const richTextField = RichTextField(modalTitle: Text('any'), placeholder: 'any', errorText: fakeErrorText);

      await pumpProviderScoped(tester, richTextField);
      await tester.tap(find.byType(RichTextField));
      await tester.pumpAndSettle();

      final wrapperContainer = find.byType(Container).first.evaluate().single.widget as Container;
      final containerDecoration = wrapperContainer.decoration! as BoxDecoration;
      final containerBorder = containerDecoration.border! as Border;

      expect(containerBorder.top.color, expectedColor);
      expect(containerBorder.right.color, expectedColor);
      expect(containerBorder.bottom.color, expectedColor);
      expect(containerBorder.left.color, expectedColor);
    });
  });
}
