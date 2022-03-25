import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/constants/images.dart' as images;
import 'package:memo/application/widgets/theme/custom_button.dart';

import '../../../utils/widget_pump.dart';

void main() {
  group('PrimaryElevatedButton -', () {
    const buttonColor = Colors.red;
    final normalColor = buttonColor.shade400;
    const pressedColor = buttonColor;
    final disabledColor = buttonColor.withOpacity(0.4);

    testWidgets('should init with normal background color when onPressed is not null', (tester) async {
      final primaryButton = PrimaryElevatedButton(text: 'test', onPressed: () {}, backgroundColor: buttonColor);

      await _pumpWithBackgroundColor(tester, primaryButton, normalColor);
    });

    testWidgets('should update its background color when disabled', (tester) async {
      const primaryButton = PrimaryElevatedButton(text: 'test', backgroundColor: buttonColor);

      await _pumpWithBackgroundColor(tester, primaryButton, disabledColor);
    });

    testWidgets('should update its background color when pressed', (tester) async {
      final primaryButton = PrimaryElevatedButton(text: 'test', onPressed: () {}, backgroundColor: buttonColor);

      await _pumpAndPressWithBackgroundColor(tester, primaryButton, pressedColor);
    });

    testWidgets('should not update its background color when pressed without onPressed', (tester) async {
      const primaryButton = PrimaryElevatedButton(text: 'test', backgroundColor: buttonColor);

      await _pumpAndPressWithBackgroundColor(tester, primaryButton, disabledColor);
    });

    testWidgets('must fill available width', (tester) async {
      const constrainedWidth = 140.0;
      const primaryButton = SizedBox(width: constrainedWidth, child: PrimaryElevatedButton(text: 'test'));

      await pumpProviderScoped(tester, primaryButton);

      final buttonRenderBox = find.byType(PrimaryElevatedButton).first.evaluate().single.renderObject! as RenderBox;
      expect(buttonRenderBox.size.width, constrainedWidth);
    });

    testWidgets('should trigger onPressed when tapped', (tester) async {
      var hasPressed = false;
      final primaryButton = PrimaryElevatedButton(text: 'test', onPressed: () => hasPressed = true);

      await _pumpAndTap(tester, primaryButton);

      expect(hasPressed, true);
    });
  });

  group('SecondaryElevatedButton -', () {
    const buttonColor = Colors.red;
    final normalColor = buttonColor.shade700;
    final pressedColor = buttonColor.shade800;
    final disabledColor = buttonColor.shade800.withOpacity(0.4);

    testWidgets('should init with normal background color when onPressed is not null', (tester) async {
      final secondaryButton = SecondaryElevatedButton(text: 'test', onPressed: () {}, backgroundColor: buttonColor);

      await _pumpWithBackgroundColor(tester, secondaryButton, normalColor);
    });

    testWidgets('should update its background color when disabled', (tester) async {
      const secondaryButton = SecondaryElevatedButton(text: 'test', backgroundColor: buttonColor);

      await _pumpWithBackgroundColor(tester, secondaryButton, disabledColor);
    });

    testWidgets('should update its background color when pressed', (tester) async {
      final secondaryButton = SecondaryElevatedButton(text: 'test', onPressed: () {}, backgroundColor: buttonColor);

      await _pumpAndPressWithBackgroundColor(tester, secondaryButton, pressedColor);
    });

    testWidgets('should not update its background color when pressed without onPressed', (tester) async {
      const secondaryButton = SecondaryElevatedButton(text: 'test', backgroundColor: buttonColor);

      await _pumpAndPressWithBackgroundColor(tester, secondaryButton, disabledColor);
    });

    testWidgets('must fill available width', (tester) async {
      const constrainedWidth = 140.0;
      const primaryButton = SizedBox(width: constrainedWidth, child: PrimaryElevatedButton(text: 'test'));

      await pumpProviderScoped(tester, primaryButton);

      final buttonRenderBox = find.byType(PrimaryElevatedButton).first.evaluate().single.renderObject! as RenderBox;
      expect(buttonRenderBox.size.width, constrainedWidth);
    });

    testWidgets('should trigger onPressed when tapped', (tester) async {
      var hasPressed = false;
      final secondaryButton = SecondaryElevatedButton(text: 'test', onPressed: () => hasPressed = true);

      await _pumpAndTap(tester, secondaryButton);

      expect(hasPressed, true);
    });
  });

  group('CustomTextButton -', () {
    const buttonColor = Colors.red;
    final normalColor = buttonColor.shade300;
    final pressedColor = buttonColor.shade400;
    final disabledColor = buttonColor.shade400.withOpacity(0.4);

    testWidgets('should init with normal text color when onPressed is not null', (tester) async {
      final textButton = CustomTextButton(text: 'test', onPressed: () {}, color: buttonColor);

      await pumpProviderScoped(tester, textButton);

      final text = tester.widget(find.byType(Text)) as Text;
      expect(text.style!.color, normalColor);
    });

    testWidgets('should update its text color when disabled', (tester) async {
      const textButton = CustomTextButton(text: 'test', color: buttonColor);

      await pumpProviderScoped(tester, textButton);

      final text = tester.widget(find.byType(Text)) as Text;
      expect(text.style!.color, disabledColor);
    });

    testWidgets('should update its text color when pressed', (tester) async {
      final textButton = CustomTextButton(text: 'test', onPressed: () {}, color: buttonColor);

      await _pumpAndPress(tester, textButton);

      final text = tester.widget(find.byType(Text)) as Text;
      expect(text.style!.color, pressedColor);
    });

    testWidgets('should not update its text color when pressed without onPressed', (tester) async {
      const textButton = CustomTextButton(text: 'test', color: buttonColor);

      await _pumpAndPress(tester, textButton);

      final text = tester.widget(find.byType(Text)) as Text;
      expect(text.style!.color, disabledColor);
    });

    testWidgets('should update its leading asset color to be the same as the button', (tester) async {
      final textButton = CustomTextButton(
        text: 'test',
        onPressed: () {},
        color: buttonColor,
        leadingAsset: images.chevronLeftAsset,
      );

      await pumpProviderScoped(tester, textButton);
      await tester.pump();

      final buttonLeadingAsset = tester.widget(find.byType(Image)) as Image;
      expect(buttonLeadingAsset.color, normalColor);
    });

    testWidgets('should trigger onPressed when tapped', (tester) async {
      var hasPressed = false;
      final textButton = CustomTextButton(text: 'test', onPressed: () => hasPressed = true);

      await _pumpAndTap(tester, textButton);

      expect(hasPressed, true);
    });

    testWidgets('must shrink based on its content', (tester) async {
      const expectedWidth = 64.0;
      const textButton = CustomTextButton(text: 'Text');

      await pumpProviderScoped(tester, textButton);

      final buttonRenderBox = find.byType(CustomTextButton).first.evaluate().single.renderObject! as RenderBox;
      expect(buttonRenderBox.size.width, expectedWidth);
    });
  });
}

/// Pumps [button] and asserts that its background color equals to [backgroundColor].
Future<void> _pumpWithBackgroundColor(WidgetTester tester, Widget button, Color backgroundColor) async {
  await pumpProviderScoped(tester, button);

  final buttonContainer = tester.widget(find.byType(Container)) as Container;
  final buttonDecoration = buttonContainer.decoration! as BoxDecoration;
  expect(buttonDecoration.color, backgroundColor);
}

/// Pumps [button] and taps it.
Future<void> _pumpAndTap<T extends Widget>(WidgetTester tester, T button) async {
  await pumpProviderScoped(tester, button);
  await tester.tap(find.byType(T));
  await tester.pump();
}

/// Pumps [button] and press (a single pointer down gesture) it.
Future<void> _pumpAndPress<T extends Widget>(WidgetTester tester, T button) async {
  await pumpProviderScoped(tester, button);
  await tester.startGesture(Offset.zero);
  await tester.pump();
}

/// Pumps [button], press it and asserts that its background color equals to [backgroundColor].
Future<void> _pumpAndPressWithBackgroundColor(WidgetTester tester, Widget button, Color backgroundColor) async {
  await _pumpAndPress(tester, button);

  final buttonContainer = tester.widget(find.byType(Container)) as Container;
  final buttonDecoration = buttonContainer.decoration! as BoxDecoration;
  expect(buttonDecoration.color, backgroundColor);
}
