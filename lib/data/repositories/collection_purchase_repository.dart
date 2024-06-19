import 'package:memo/data/gateways/purchase_gateway.dart';
import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/repositories/collection_repository.dart';
import 'package:memo/data/serializers/collection_serializer.dart';

abstract class CollectionPurchaseRepository {
  /// Purchase products in the app with the store ID [storeId] for the local user.
  Future<void> purchaseInApp({required String storeId});

  /// Receives purchase information made by the user.
  Future<List<String>> getPurchasesInfo();

  /// Check which products are available for purchase.
  Future<List<String>> isAvailable();

  /// Updates the collection with the [id] to be premium or not.
  Future<void> updatePurchaseCollection({required String id, required bool isPremium});
}

class CollectionPurchaseRepositoryImpl implements CollectionPurchaseRepository {
  CollectionPurchaseRepositoryImpl(this._db, this._purchaseGateway, this.collectionRepo);

  final SembastDatabase _db;
  final _collectionStore = 'collections';

  final PurchaseGateway _purchaseGateway;

  final CollectionRepository collectionRepo;

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
  Future<void> updatePurchaseCollection({required String id, required bool isPremium}) => _db.put(
        id: id,
        object: <String, dynamic>{
          CollectionKeys.isPremium: isPremium,
        },
        store: _collectionStore,
      );
}
