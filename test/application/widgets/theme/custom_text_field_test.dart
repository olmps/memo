import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/widgets/theme/custom_text_field.dart';

import '../../../utils/widget_pump.dart';

void main() {
  group('Editing State - ', () {
    testWidgets('should have the expected text in the controller after typing in the TextField', (tester) async {
      final controller = TextEditingController();
      final textField = CustomTextField(controller: controller);
      const expectedText = 'any';

      await pumpMaterialScopedWithTheme(tester, textField);
      await tester.enterText(find.byType(CustomTextField), expectedText);

      expect(controller.text, expectedText);
    });

    testWidgets('should have focus when tapping in the TextField', (tester) async {
      final focusNode = FocusNode();
      final textField = CustomTextField(focusNode: focusNode);

      await pumpMaterialScopedWithTheme(tester, textField);
      expect(focusNode.hasFocus, false);

      await tester.tapAt(Offset.zero);
      expect(focusNode.hasFocus, true);
    });

    testWidgets('should show clear button when has text and showsClearIcon is true', (tester) async {
      // ignore: avoid_redundant_argument_values
      const textField = CustomTextField(showsClearIcon: true);

      await pumpMaterialScopedWithTheme(tester, textField);
      var renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, null);

      await tester.enterText(find.byType(CustomTextField), 'any');
      await tester.pumpAndSettle();

      renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, isA<IconButton>());
    });

    testWidgets('should show custom suffix icon when not focused', (tester) async {
      final suffixIcon = Container(color: Colors.red);
      final textField = CustomTextField(suffixIcon: suffixIcon);

      await pumpMaterialScopedWithTheme(tester, textField);

      final renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, suffixIcon);
    });

    testWidgets('should replace custom suffix icon by clear button when editing', (tester) async {
      final suffixIcon = Container(color: Colors.red);
      final textField = CustomTextField(suffixIcon: suffixIcon);

      await pumpMaterialScopedWithTheme(tester, textField);
      var renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, suffixIcon);

      await tester.enterText(find.byType(CustomTextField), 'any');
      await tester.pumpAndSettle();

      renderedTextField = find.byType(TextField).first.evaluate().single.widget as TextField;
      expect(renderedTextField.decoration!.suffixIcon, isA<IconButton>());
    });
  });

  group('Error State - ', () {
    testWidgets('should present error label when errorText is not null', (tester) async {
      const errorText = 'any';
      const textField = CustomTextField(errorText: errorText);

      await pumpMaterialScopedWithTheme(tester, textField);

      final errorTextWidget = find.byType(Text).last.evaluate().single.widget as Text;
      expect(errorTextWidget.data, errorText);
    });

    testWidgets('should have a destructive border when errorText is not null', (tester) async {
      const errorText = 'any';
      const textField = CustomTextField(errorText: errorText);
      final expectedColor = ThemeController().state.destructiveSwatch;

      await pumpMaterialScopedWithTheme(tester, textField);

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
