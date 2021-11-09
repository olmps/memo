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

    testWidgets('should inits with normal background color when onPressed is not null', (tester) async {
      final primaryButton = PrimaryElevatedButton(text: 'test', onPressed: () {}, backgroundColor: buttonColor);

      await pumpProviderScoped(tester, primaryButton);

      final buttonContainer = tester.widget(find.byType(Container)) as Container;
      final buttonDecoration = buttonContainer.decoration! as BoxDecoration;
      expect(buttonDecoration.color, normalColor);
    });

    testWidgets('should update its background color when disabled', (tester) async {
      const primaryButton = PrimaryElevatedButton(text: 'test', backgroundColor: buttonColor);

      await pumpProviderScoped(tester, primaryButton);

      final buttonContainer = tester.widget(find.byType(Container)) as Container;
      final buttonDecoration = buttonContainer.decoration! as BoxDecoration;
      expect(buttonDecoration.color, disabledColor);
    });

    testWidgets('should update its background color when pressed', (tester) async {
      final primaryButton = PrimaryElevatedButton(text: 'test', onPressed: () {}, backgroundColor: buttonColor);

      await pumpProviderScoped(tester, primaryButton);
      await tester.startGesture(const Offset(0, 0));
      await tester.pump();

      final buttonContainer = tester.widget(find.byType(Container)) as Container;
      final buttonDecoration = buttonContainer.decoration! as BoxDecoration;
      expect(buttonDecoration.color, pressedColor);
    });

    testWidgets('should not update its background color when pressed without onPressed', (tester) async {
      const primaryButton = PrimaryElevatedButton(text: 'test', backgroundColor: buttonColor);

      await pumpProviderScoped(tester, primaryButton);
      await tester.startGesture(const Offset(0, 0));
      await tester.pump();

      final buttonContainer = tester.widget(find.byType(Container)) as Container;
      final buttonDecoration = buttonContainer.decoration! as BoxDecoration;
      expect(buttonDecoration.color, disabledColor);
    });

    testWidgets('should trigger onPressed when tapped', (tester) async {
      var hasPressed = false;
      final primaryButton = PrimaryElevatedButton(text: 'test', onPressed: () => hasPressed = true);

      await pumpProviderScoped(tester, primaryButton);
      await tester.tap(find.byType(PrimaryElevatedButton));
      await tester.pump();

      expect(hasPressed, true);
    });
  });

  group('SecondaryElevatedButton -', () {
    const buttonColor = Colors.red;
    final normalColor = buttonColor.shade700;
    final pressedColor = buttonColor.shade800;
    final disabledColor = buttonColor.shade800.withOpacity(0.4);

    testWidgets('should inits with normal background color when onPressed is not null', (tester) async {
      final secondaryButton = SecondaryElevatedButton(text: 'test', onPressed: () {}, backgroundColor: buttonColor);

      await pumpProviderScoped(tester, secondaryButton);

      final buttonContainer = tester.widget(find.byType(Container)) as Container;
      final buttonDecoration = buttonContainer.decoration! as BoxDecoration;
      expect(buttonDecoration.color, normalColor);
    });

    testWidgets('should update its background color when disabled', (tester) async {
      const secondaryButton = SecondaryElevatedButton(text: 'test', backgroundColor: buttonColor);

      await pumpProviderScoped(tester, secondaryButton);

      final buttonContainer = tester.widget(find.byType(Container)) as Container;
      final buttonDecoration = buttonContainer.decoration! as BoxDecoration;
      expect(buttonDecoration.color, disabledColor);
    });

    testWidgets('should update its background color when pressed', (tester) async {
      final secondaryButton = SecondaryElevatedButton(text: 'test', onPressed: () {}, backgroundColor: buttonColor);

      await pumpProviderScoped(tester, secondaryButton);
      await tester.startGesture(const Offset(0, 0));
      await tester.pump();

      final buttonContainer = tester.widget(find.byType(Container)) as Container;
      final buttonDecoration = buttonContainer.decoration! as BoxDecoration;
      expect(buttonDecoration.color, pressedColor);
    });

    testWidgets('should not update its background color when pressed without onPressed', (tester) async {
      const secondaryButton = SecondaryElevatedButton(text: 'test', backgroundColor: buttonColor);

      await pumpProviderScoped(tester, secondaryButton);
      await tester.startGesture(const Offset(0, 0));
      await tester.pump();

      final buttonContainer = tester.widget(find.byType(Container)) as Container;
      final buttonDecoration = buttonContainer.decoration! as BoxDecoration;
      expect(buttonDecoration.color, disabledColor);
    });

    testWidgets('should trigger onPressed when tapped', (tester) async {
      var hasPressed = false;
      final secondaryButton = SecondaryElevatedButton(text: 'test', onPressed: () => hasPressed = true);

      await pumpProviderScoped(tester, secondaryButton);
      await tester.tap(find.byType(SecondaryElevatedButton));
      await tester.pump();

      expect(hasPressed, true);
    });
  });

  group('CustomTextButton -', () {
    const buttonColor = Colors.red;
    final normalColor = buttonColor.shade300;
    final pressedColor = buttonColor.shade400;
    final disabledColor = buttonColor.shade400.withOpacity(0.4);

    testWidgets('should inits with normal text color when onPressed is not null', (tester) async {
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

      await pumpProviderScoped(tester, textButton);
      await tester.startGesture(const Offset(0, 0));
      await tester.pump();

      final text = tester.widget(find.byType(Text)) as Text;
      expect(text.style!.color, pressedColor);
    });

    testWidgets('should not update its text color when pressed without onPressed', (tester) async {
      const textButton = CustomTextButton(text: 'test', color: buttonColor);

      await pumpProviderScoped(tester, textButton);
      await tester.startGesture(const Offset(0, 0));
      await tester.pump();

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

      await pumpProviderScoped(tester, textButton);
      await tester.tap(find.byType(CustomTextButton));
      await tester.pump();

      expect(hasPressed, true);
    });
  });
}
