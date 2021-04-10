import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/theme/theme_controller.dart';

void main() {
  test('ThemeController should use the predefined default state', () {
    final container = ProviderContainer();
    final themeData = container.read(themeProvider.state);

    expect(themeData.theme, ThemeController.defaultTheme);
  });

  test('ThemeController should not trigger an update when changing the theme to the same as the actual', () {
    final container = ProviderContainer();
    final themeNotifier = container.read(themeProvider);

    var listenerCalls = 0;
    final stateListener = container.listen(
      themeProvider.state,
      didChange: (sub) {
        listenerCalls++;
      },
    );

    themeNotifier.changeTheme(ThemeController.defaultTheme);
    stateListener.flush();
    expect(listenerCalls, 0);
  });

  // TODO(matuella): Implement this test when multiple themes are available
  // test('ThemeNotifier should trigger an update when changing the theme', () {
  //   final container = ProviderContainer();
  //   final themeNotifier = container.read(themeProvider);

  //   var updatedCount = 0;
  //   final stateListener = container.listen(
  //     themeProvider.state,
  //     didChange: (sub) {
  //       updatedCount++;
  //     },
  //   );

  //   themeNotifier.changeTheme(MemoTheme.MY_NEW_THEME);
  //   stateListener.flush();
  //   expect(updatedCount, 1);
  // });
}
