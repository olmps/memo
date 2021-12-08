import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/widgets/unfocus_pointer.dart';

import '../../utils/widget_pump.dart';

void main() {
  testWidgets('should request unfocus when tapping non-interactable child elements', (tester) async {
    final textFieldFocus = FocusNode();
    final containerKey = UniqueKey();
    final unfocusDetector = UnfocusPointer(
      child: Column(
        children: [
          TextField(focusNode: textFieldFocus),
          Container(key: containerKey, height: 10, width: 10, color: Colors.red),
        ],
      ),
    );

    await pumpProviderScoped(tester, unfocusDetector);
    expect(textFieldFocus.hasFocus, false);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(textFieldFocus.hasFocus, true);

    await tester.tap(find.byKey(containerKey));
    await tester.pumpAndSettle();
    expect(textFieldFocus.hasFocus, false);
  });
}
