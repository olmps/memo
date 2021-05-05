import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Failed to open an URL for any specific reason
class UrlException extends BaseException {
  UrlException.failedToOpen({String? debugInfo}) : super(type: ExceptionType.failedToOpenUrl, debugInfo: debugInfo);
}
