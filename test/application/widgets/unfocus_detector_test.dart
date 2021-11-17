import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/widgets/unfocus_detector.dart';

import '../../utils/widget_pump.dart';

void main() {
  testWidgets('should request unfocus when tapping outside', (tester) async {
    final textFieldFocus = FocusNode();
    final unfocusDetector = SizedBox.square(
      dimension: 300,
      child: UnfocusDetector(
        child: Center(
          child: SizedBox.square(
            dimension: 100,
            child: TextField(focusNode: textFieldFocus),
          ),
        ),
      ),
    );

    await pumpProviderScoped(tester, unfocusDetector);
    expect(textFieldFocus.hasFocus, false);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(textFieldFocus.hasFocus, true);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(textFieldFocus.hasFocus, false);
  });
}
