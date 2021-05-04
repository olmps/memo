import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Failed to open an URL for any specific reason
class URLException extends BaseException {
  URLException.failedToOpen({String? debugInfo}) : super(type: ExceptionType.failedToOpenURL, debugInfo: debugInfo);
}
