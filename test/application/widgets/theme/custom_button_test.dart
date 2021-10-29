import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';

import '../../../utils/widget_pump.dart';

void main() {
  group('Custom Buttons -', () {
    testWidgets('should be at the `normal` state with a `onPressed` argument and when not pressed', (tester) async {
      final primaryButton = PrimaryElevatedButton(text: 'teste', onPressed: () {});

      await pumpMaterialScopedWithTheme(tester, primaryButton);

      final buttonState = tester.state<CustomButtonState>(find.byType(CustomButton));

      expect(buttonState.state == ButtonState.normal, true);
    });

    testWidgets('should be at the `disable` state with a `null` `onPressed` argument and when not pressed',
        (tester) async {
      const primaryButton = PrimaryElevatedButton(text: 'teste');

      await pumpMaterialScopedWithTheme(tester, primaryButton);

      final buttonState = tester.state<CustomButtonState>(find.byType(CustomButton));

      expect(buttonState.state == ButtonState.disabled, true);
    });

    testWidgets('should be at the `pressed` state with a `onPressed` argument and when pressed', (tester) async {
      final primaryButton = PrimaryElevatedButton(text: 'teste', onPressed: () {});

      await pumpMaterialScopedWithTheme(tester, primaryButton);

      await tester.startGesture(const Offset(0, 0));

      await tester.pump();

      final buttonState = tester.state<CustomButtonState>(find.byType(CustomButton));

      expect(buttonState.state == ButtonState.pressed, true);
    });

    testWidgets('should be at the `disable` state with a `null` `onPressed` argument and when pressed', (tester) async {
      const primaryButton = PrimaryElevatedButton(text: 'teste');

      await pumpMaterialScopedWithTheme(tester, primaryButton);

      await tester.startGesture(const Offset(0, 0));

      await tester.pump();

      final buttonState = tester.state<CustomButtonState>(find.byType(CustomButton));

      expect(buttonState.state == ButtonState.disabled, true);
    });
  });
}
