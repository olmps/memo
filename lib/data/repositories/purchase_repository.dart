import 'package:memo/data/gateways/purchase_gateway.dart';
import 'package:memo/data/gateways/sembast_database.dart';

abstract class PurchaseRepository {
  /// Purchase products in the app with the store ID [storeId] for the local user.
  Future<void> purchaseInApp({required String storeId});

  /// Receives purchase information made by the user.
  Future<List<String>> getPurchasesInfo();

  /// Check which products are available for purchase.
  Future<List<String>> isAvailable();

  /// Updates the collection with the [id] to be premium or not.
  Future<void> updatePurchase({required String purchaseId});

  Future<List<String>> getPurchaseProducts();
}

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl(this._db, this._purchaseGateway);

  final SembastDatabase _db;
  final _purchasesStore = 'purchases';

  final PurchaseGateway _purchaseGateway;

  @override
  Future<void> purchaseInApp({required String storeId}) => _purchaseGateway.purchase(
        identifier: storeId,
      );

  @override
  Future<List<String>> getPurchasesInfo() async {
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
          'purchasesId': purchaseId,
        },
        store: _purchasesStore,
      );

  @override
  Future<List<String>> getPurchaseProducts() async {
    final purchases = await _db.getAll(store: _purchasesStore);
    return purchases.map((purchase) => purchase['purchasesId'] as String).toList();
  }
}
