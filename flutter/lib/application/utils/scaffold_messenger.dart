import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/constants/exception_strings.dart';
import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Unique [GlobalKey] that handles the application's global [ScaffoldMessengerState].
///
/// This key must be provided to the application's root [MaterialApp.scaffoldMessengerKey], otherwise scaffold utilities
/// (like [showSnackBar]) won't work.
final scaffoldMessenger = Provider((_) => GlobalKey<ScaffoldMessengerState>());

/// Shows the [snackBar] using the current [scaffoldMessenger].
void showSnackBar(WidgetRef ref, SnackBar snackBar) => ref.read(scaffoldMessenger).currentState?.showSnackBar(snackBar);

/// Shows a message for the [exception] using [showSnackBar].
void showExceptionSnackBar(WidgetRef ref, BaseException exception) {
  final content = Text(descriptionForException(exception));
  final exceptionSnackBar = SnackBar(content: content);
  showSnackBar(ref, exceptionSnackBar);
}
