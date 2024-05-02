import 'package:memo/core/faults/exceptions/base_exception.dart';

/// Failed to purchase a deck for any specific reason.
class PurchaseException extends BaseException {
  PurchaseException.failedPurchase() : super(type: ExceptionType.failedPurchase);
}
