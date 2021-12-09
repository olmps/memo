import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/widgets/theme/terminal_window.dart';
import 'package:mocktail/mocktail.dart';

import '../../../utils/mocks.dart';
import '../../../utils/widget_pump.dart';

void main() {
  testWidgets('should forward gestures to its child', (tester) async {
    final onTap = MockCallbackFunction();
    final containerKey = UniqueKey();
    final terminalBody = GestureDetector(
      onTap: onTap,
      child: Container(key: containerKey, color: Colors.red),
    );
    final terminal = TerminalWindow(
      body: terminalBody,
      borderColor: Colors.red,
      fadeGradient: const [Colors.red, Colors.red],
    );

    await pumpProviderScoped(tester, terminal);

    await tester.tap(find.byKey(containerKey));
    await tester.pumpAndSettle();

    verify(onTap.call).called(1);
  });
}
