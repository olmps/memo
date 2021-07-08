import 'package:memo/core/faults/errors/base_error.dart';

/// Failure while parsing any object instance to/from a raw value.
class SerializationError extends BaseError {
  SerializationError(String message) : super(type: ErrorType.serialization, message: message);
}
