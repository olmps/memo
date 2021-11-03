import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';

import '../../../utils/widget_pump.dart';

void main() {
  group('Custom Buttons -', () {
    testWidgets('should init with `normal` state when `onPressed` is not null', (tester) async {
      final primaryButton = PrimaryElevatedButton(text: 'test', onPressed: () {});

      await pumpMaterialScopedWithTheme(tester, primaryButton);

      final buttonState = tester.state<CustomButtonState>(find.byType(CustomButton));

      expect(buttonState.state == ButtonState.normal, true);
    });

    testWidgets('should stay in `disable` state when `onPressed` is `null`', (tester) async {
      const primaryButton = PrimaryElevatedButton(text: 'test');

      await pumpMaterialScopedWithTheme(tester, primaryButton);

      final buttonState = tester.state<CustomButtonState>(find.byType(CustomButton));

      expect(buttonState.state == ButtonState.disabled, true);
    });

    testWidgets('should update to `pressed` state when tapped and `onPressed` is not `null`', (tester) async {
      final primaryButton = PrimaryElevatedButton(text: 'test', onPressed: () {});

      await pumpMaterialScopedWithTheme(tester, primaryButton);

      await tester.startGesture(const Offset(0, 0));

      await tester.pump();

      final buttonState = tester.state<CustomButtonState>(find.byType(CustomButton));

      expect(buttonState.state == ButtonState.pressed, true);
    });

    testWidgets("shouldn't change to `pressed` when tapped and `onPressed` is `null`", (tester) async {
      const primaryButton = PrimaryElevatedButton(text: 'test');

      await pumpMaterialScopedWithTheme(tester, primaryButton);

      await tester.startGesture(const Offset(0, 0));

      await tester.pump();

      final buttonState = tester.state<CustomButtonState>(find.byType(CustomButton));

      expect(buttonState.state == ButtonState.disabled, true);
    });
  });
}
