import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps the [widget] in a [Scaffold] and [MaterialApp]
Future<void> pumpMaterialScoped(WidgetTester tester, Widget widget) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      ),
    );
