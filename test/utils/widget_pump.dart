import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/theme/theme_controller.dart';

/// Wraps the [widget] in a [Scaffold] and [MaterialApp]
Future<void> pumpMaterialScoped(WidgetTester tester, Widget widget) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      ),
    );

/// Wraps a [pumpMaterialScoped] with a [ProviderScope] that overrides [themeController] and optional [overrides].
Future<void> pumpThemedProviderScoped(WidgetTester tester, Widget widget, [List<Override> overrides = const []]) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: overrides..add(themeController.overrideWithValue(ThemeController())),
        child: MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      ),
    );
