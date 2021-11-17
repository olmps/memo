import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Expected failures that occurs when handling with user input.
class ValidationException extends BaseException {
  /// Thrown when the user left an required field empty.
  ValidationException.emptyField()
      : amount = null,
        super(type: ExceptionType.emptyField);

  /// Thrown when the user exceeded the characters amount for a given field.
  ValidationException.fieldLengthExceeded(int maxLength)
      : amount = maxLength,
        super(type: ExceptionType.fieldLengthExceeded);

  /// Helps to provide a more accurate error description for a validation exception.
  final int? amount;
}
