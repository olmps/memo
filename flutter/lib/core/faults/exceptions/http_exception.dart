import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Expected failures that occurs while communicating with http.
class HttpException extends BaseException {
  /// Thrown when a request failed to be fulfilled by several reasons.
  HttpException.failedRequest({required String debugInfo})
      : super(type: ExceptionType.failedRequest, debugInfo: debugInfo);
}
