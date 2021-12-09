import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Expected failures that occurs when handling with user input.
class ValidationException extends BaseException {
  /// Thrown when the user left an required field empty.
  ValidationException.emptyField() : super(type: ExceptionType.emptyField);

  /// Thrown when the user exceeded the characters amount for a given field.
  ValidationException.fieldLengthExceeded(String message)
      : super(type: ExceptionType.fieldLengthExceeded, message: message);
}
