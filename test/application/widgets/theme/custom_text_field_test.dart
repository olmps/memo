import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/theme/custom_text_field.dart';

import '../../../utils/widget_pump.dart';

void main() {
  group('Editing State - ', () {
    testWidgets('should have the expected text in the controller after typing', (tester) async {
      final controller = TextEditingController();
      final textField = CustomTextField(controller: controller);
      const expectedText = 'any';

      await pumpThemedProviderScoped(tester, textField);
      await tester.enterText(find.byType(CustomTextField), expectedText);

      expect(controller.text, expectedText);
    });

    testWidgets('should have focus when tapped', (tester) async {
      final focusNode = FocusNode();
      final textField = CustomTextField(focusNode: focusNode);

      await pumpThemedProviderScoped(tester, textField);
      expect(focusNode.hasFocus, false);

      await tester.tapAt(Offset.zero);
      expect(focusNode.hasFocus, true);
    });

    testWidgets('should show clear button when has text and showsClearIcon is true', (tester) async {
      // ignore: avoid_redundant_argument_values
      const textField = CustomTextField(showsClearIcon: true);

      await pumpThemedProviderScoped(tester, textField);
      var renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, null);

      await tester.enterText(find.byType(CustomTextField), 'any');
      await tester.pumpAndSettle();

      renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, isA<IconButton>());
    });
  });

  group('Suffix Icon', () {
    testWidgets('should show custom suffix icon when not focused', (tester) async {
      final suffixIcon = Container(color: Colors.red);
      final textField = CustomTextField(suffixIcon: suffixIcon);

      await pumpThemedProviderScoped(tester, textField);

      final renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, suffixIcon);
    });

    testWidgets('should show custom suffix icon when focused but with empty text', (tester) async {
      final suffixIcon = Container(color: Colors.red);
      final textField = CustomTextField(suffixIcon: suffixIcon);

      await pumpThemedProviderScoped(tester, textField);
      await tester.enterText(find.byType(CustomTextField), '');

      final renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, suffixIcon);
    });

    testWidgets('should show custom suffix icon when editing and showClearIcon is false', (tester) async {
      final suffixIcon = Container(color: Colors.red);
      final textField = CustomTextField(suffixIcon: suffixIcon, showsClearIcon: false);

      await pumpThemedProviderScoped(tester, textField);
      await tester.enterText(find.byType(CustomTextField), 'any');

      final renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, suffixIcon);
    });

    testWidgets('should show clear button when has text, is focused and showsClearIcon is true', (tester) async {
      final suffixIcon = Container(color: Colors.red);
      final textField = CustomTextField(suffixIcon: suffixIcon);

      await pumpThemedProviderScoped(tester, textField);
      var renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, suffixIcon);

      await tester.enterText(find.byType(CustomTextField), 'any');
      await tester.pumpAndSettle();

      renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, isA<IconButton>());
    });
  });

  group('Labels - ', () {
    group('Error Label - ', () {
      testWidgets('should present error label when errorText is not null', (tester) async {
        const errorText = 'any';
        const textField = CustomTextField(errorText: errorText);

        await pumpThemedProviderScoped(tester, textField);

        final errorTextWidget = find.text(errorText);
        expect(errorTextWidget, findsOneWidget);
      });

      testWidgets('should have a destructive border when errorText is not null', (tester) async {
        const errorText = 'any';
        const textField = CustomTextField(errorText: errorText);
        final expectedColor = ThemeController().state.destructiveSwatch;

        await pumpThemedProviderScoped(tester, textField);

        final wrapperContainer = find.byType(Container).first.evaluate().single.widget as Container;
        final containerDecoration = wrapperContainer.decoration! as BoxDecoration;
        final containerBorder = containerDecoration.border! as Border;

        expect(containerBorder.top.color, expectedColor);
        expect(containerBorder.right.color, expectedColor);
        expect(containerBorder.bottom.color, expectedColor);
        expect(containerBorder.left.color, expectedColor);
      });

      testWidgets('should precede helperText when both are present', (tester) async {
        const errorText = 'error text';
        const helperText = 'helper text';
        const textField = CustomTextField(errorText: errorText, helperText: helperText);

        await pumpThemedProviderScoped(tester, textField);

        final errorTextWidget = find.text(errorText);
        final helperTextWidget = find.text(helperText);

        expect(errorTextWidget, findsOneWidget);
        expect(helperTextWidget, findsNothing);
      });
    });

    group('Helper Label', () {
      testWidgets('should present helper label when helperText is not null', (tester) async {
        const helperText = 'any';
        const textField = CustomTextField(helperText: helperText);

        await pumpThemedProviderScoped(tester, textField);

        final helperTextWidget = find.text(helperText);
        expect(helperTextWidget, findsOneWidget);
      });
    });
  });
}
