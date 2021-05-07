import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Exposes a unique [GlobalKey] that handles the application's global [ScaffoldMessengerState]
///
/// This same key must be provided to the application's root [MaterialApp]
final scaffoldMessenger = Provider((_) => GlobalKey<ScaffoldMessengerState>());
GlobalKey<ScaffoldMessengerState> useScaffoldMessenger() => useProvider(scaffoldMessenger);

extension SnackBarContext on BuildContext {
  /// Shows the [snackBar] using the current [scaffoldMessenger]
  void showSnackBar(SnackBar snackBar) => read(scaffoldMessenger).currentState?.showSnackBar(snackBar);
}

extension ExceptionHandler on BuildContext {
  /// Shows a suitable message for the [exception] in a [SnackBar] widget
  void showExceptionSnackBar(BaseException exception) {
    final content = Text(_descriptionForException(exception));
    final exceptionSnackBar = SnackBar(content: content);
    showSnackBar(exceptionSnackBar);
  }

  String _descriptionForException(BaseException exception) {
    switch (exception.type) {
      case ExceptionType.failedToOpenUrl:
        return 'Algo deu errado ao tentar abrir o link!';
    }
  }
}
