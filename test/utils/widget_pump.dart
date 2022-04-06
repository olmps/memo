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

/// Wraps a [pumpMaterialScoped] with a [ProviderScope] that optionally uses [overrides].
Future<void> pumpProviderScoped(WidgetTester tester, Widget widget, [List<Override> overrides = const []]) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: Consumer(
          builder: (context, ref, child) {
            return MaterialApp(
              theme: ref.read(themeController.notifier).currentThemeData(context),
              home: Scaffold(body: widget),
            );
          },
        ),
      ),
    );
