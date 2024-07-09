import 'package:memo/data/gateways/purchase_gateway.dart';
import 'package:memo/data/gateways/sembast_database.dart';

abstract class PurchaseRepository {
  /// Purchase products in the app with the store ID [storeId] for the local user.
  Future<void> purchaseInApp({required String storeId});

  /// Fetches a list of RevenueCat purchase information strings by user id.
  ///
  /// This function retrieves purchase information asynchronously
  /// and returns a list of strings, where each string represents a purchase.
  Future<List<String>> getUserPurchases();

  /// Check which products are available for purchase.
  Future<List<String>> isAvailable();

  /// Updates the collection with the [purchaseId] to be premium or not.
  Future<void> updatePurchase({required String purchaseId});

  /// Fetches a list of purchased product IDs from the local database.
  ///
  /// This function asynchronously retrieves all the purchases stored in the local database
  /// and extracts the product IDs from each purchase record.
  Future<List<String>> getPurchasedProductsIds();
}

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl(this._db, this._purchaseGateway);

  final SembastDatabase _db;
  final _purchasesStore = 'purchases';
  final _purchaseIdKey = 'purchasesId';

  final PurchaseGateway _purchaseGateway;

  @override
  Future<void> purchaseInApp({required String storeId}) => _purchaseGateway.purchase(
        identifier: storeId,
      );

  @override
  Future<List<String>> getUserPurchases() async {
    final info = await _purchaseGateway.purchasesInfo();
    return info.map((purchase) => purchase).toList();
  }

  @override
  Future<List<String>> isAvailable() async {
    final products = await _purchaseGateway.getAvailableProducts();
    return products.map((product) => product.storeProduct.identifier).toList();
  }

  @override
  Future<void> updatePurchase({required String purchaseId}) => _db.put(
        id: purchaseId,
        object: <String, dynamic>{
          _purchaseIdKey: purchaseId,
        },
        store: _purchasesStore,
      );

  @override
  Future<List<String>> getPurchasedProductsIds() async {
    final purchases = await _db.getAll(store: _purchasesStore);
    return purchases.map((purchase) => purchase[_purchaseIdKey] as String).toList();
  }
}
