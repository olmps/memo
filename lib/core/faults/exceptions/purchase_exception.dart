import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Failed to purchase a deck for any specific reason.
class PurchaseException extends BaseException {
  PurchaseException.purchaseProductFailed({String? debugInfo})
      : super(type: ExceptionType.purchaseProductFailed, debugInfo: debugInfo);

  PurchaseException.failedPurchase() : super(type: ExceptionType.failedPurchase);
}
