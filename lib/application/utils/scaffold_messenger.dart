import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Unique [GlobalKey] that handles the application's global [ScaffoldMessengerState].
///
/// This key must be provided to the application's root [MaterialApp.scaffoldMessengerKey], otherwise scaffold utilities
/// (like [showSnackBar]) won't work.
final scaffoldMessenger = Provider((_) => GlobalKey<ScaffoldMessengerState>());
GlobalKey<ScaffoldMessengerState> useScaffoldMessenger() => useProvider(scaffoldMessenger);

/// Shows the [snackBar] using the current [scaffoldMessenger].
void showSnackBar(BuildContext context, SnackBar snackBar) =>
    context.read(scaffoldMessenger).currentState?.showSnackBar(snackBar);

/// Shows a message for the [exception] using [showSnackBar].
void showExceptionSnackBar(BuildContext context, BaseException exception) {
  final content = Text(_descriptionForException(exception));
  final exceptionSnackBar = SnackBar(content: content);
  showSnackBar(context, exceptionSnackBar);
}

String _descriptionForException(BaseException exception) {
  switch (exception.type) {
    case ExceptionType.failedToOpenUrl:
      return 'Algo deu errado ao tentar abrir o link!';
  }
}
