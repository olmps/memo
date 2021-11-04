import 'package:flutter/material.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/exception_strings.dart';
import 'package:memo/application/constants/strings.dart' as strings;
import 'package:memo/application/widgets/theme/custom_button.dart';
import 'package:memo/core/faults/exceptions/base_exception.dart';

/// A container that wraps a localized [exception] with a button that, when pressed, calls [onRetry].
///
/// This widget is mostly used in scenarios where a page couldn't load its essential data, meaning that there is no
/// alternative other than retry loading its contents.
class ExceptionRetryContainer extends StatelessWidget {
  const ExceptionRetryContainer({required this.onRetry, required this.exception});

  final VoidCallback onRetry;
  final BaseException exception;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(strings.oops, style: textTheme.headline4, textAlign: TextAlign.center),
        context.verticalBox(Spacing.xSmall),
        Text(
          descriptionForException(exception),
          style: textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        context.verticalBox(Spacing.large),
        PrimaryElevatedButton(
          text: strings.tryAgain,
          onPressed: onRetry,
        ),
      ],
    ).withSymmetricalPadding(context, horizontal: Spacing.medium);
  }
}
