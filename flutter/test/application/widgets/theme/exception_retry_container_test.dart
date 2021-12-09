import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/constants/exception_strings.dart';
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/application/widgets/theme/exception_retry_container.dart';
import 'package:memo/core/faults/exceptions/url_exception.dart';
import 'package:mocktail/mocktail.dart';

import '../../../utils/mocks.dart';
import '../../../utils/widget_pump.dart';

void main() {
  final fakeException = UrlException.failedToOpen();
  final mockCallback = MockCallbackFunction();
  final exceptionContainer = ExceptionRetryContainer(onRetry: mockCallback, exception: fakeException);

  testWidgets('should invoke callback when tapped', (tester) async {
    await pumpProviderScoped(tester, exceptionContainer);
    await tester.tap(find.byType(PrimaryElevatedButton));

    verify(mockCallback.call).called(1);
  });
  testWidgets('should present correct exception description', (tester) async {
    final expectedMessage = descriptionForException(fakeException);

    await pumpProviderScoped(tester, exceptionContainer);
    final exceptionText = find.text(expectedMessage);

    expect(exceptionText, findsOneWidget);
  });
}
