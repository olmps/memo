import 'dart:async';

import 'package:flutter/services.dart';
import 'package:memo/core/env.dart';
import 'package:memo/core/faults/exceptions/purchase_exception.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Handles in-app purchases.
abstract class PurchaseGateway {
  /// Purchase the product using a unique [identifier] per product.
  ///
  /// Throws a [PurchaseException.failedPurchase] if a purchase failed.
  /// Throws a [PurchaseException.purchaseProductFailed] if anything wrong happens during the purchase flow.
  Future<void> purchase({required String identifier});

  /// Get all purchases the user has made.
  Future<List<String>> purchasesInfo();

  /// Check which products are available for purchase.
  Future<List<Package>> getAvailableProducts();
}

class PurchaseGatewayImpl extends PurchaseGateway {
  PurchaseGatewayImpl(this._env);

  final EnvMetadata _env;

  bool _hasInitialized = false;

  FutureOr<void> _init() async {
    PurchasesConfiguration? configuration;
    configuration = PurchasesConfiguration(_env.inAppPurchaseKey);

    if (!_hasInitialized) {
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(configuration);

      _hasInitialized = true;
    }
  }

  @override
  Future<void> purchase({required String identifier}) async {
    try {
      await _init();
      await Purchases.purchaseProduct(identifier, type: PurchaseType.inapp);
    } on PlatformException catch (exception) {
      final errorCode = PurchasesErrorHelper.getErrorCode(exception);
      if (errorCode == PurchasesErrorCode.offlineConnectionError) {
        throw PurchaseException.failedPurchase();
      }

      throw PurchaseException.purchaseProductFailed(debugInfo: exception.toString());
    }
  }

  @override
  Future<List<String>> purchasesInfo() async {
    await _init();
    final customerInfo = await Purchases.getCustomerInfo();

    final purchases = customerInfo.allPurchasedProductIdentifiers;

    return purchases;
  }

  @override
  Future<List<Package>> getAvailableProducts() async {
    await _init();
    final offerings = await Purchases.getOfferings();

    final productIdentifiers = offerings.current!.availablePackages;

    return productIdentifiers;
  }
}
