import 'dart:async';

import 'package:memo/core/env.dart';
import 'package:memo/data/repositories/collection_repository.dart';
import 'package:memo/data/repositories/purchase_repository.dart';
import 'package:memo/domain/models/collection.dart';

abstract class CollectionPurchaseServices {
  /// Purchases the collection - from [id].
  Future<void> purchaseCollection({required String id});

  /// Verifies if the collection - from [id] - is visible to the user.
  Future<bool> isPurchased({required String id});
}

class CollectionPurchaseServicesImpl implements CollectionPurchaseServices {
  CollectionPurchaseServicesImpl({
    required this.env,
    required this.purchaseRepo,
    required this.collectionRepo,
  });

  final EnvMetadata env;

  final PurchaseRepository purchaseRepo;

  final CollectionRepository collectionRepo;

  @override
  Future<void> purchaseCollection({required String id}) async {
    final collection = await collectionRepo.getCollection(id: id);

    await _purchaseInAppCollection(collection);
    await _updatePurchaseCollection(id: id);
  }

  Future<void> _updatePurchaseCollection({required String id}) async {
    final collection = await collectionRepo.getCollection(id: id);
    final isPurchased = await purchaseRepo.getPurchasesInfo();

    if (isPurchased.contains(_collectionStore(collection))) {
      await purchaseRepo.updatePurchase(purchaseId: _collectionStore(collection));
    }
  }

  Future<void> _purchaseInAppCollection(Collection collection) async {
    await purchaseRepo.purchaseInApp(storeId: _collectionStore(collection));
  }

  String _collectionStore(Collection collection) {
    switch (env.platform) {
      case SupportedPlatform.ios:
        return collection.appStoreId;
      case SupportedPlatform.android:
        return collection.playStoreId;
    }
  }

  @override
  Future<bool> isPurchased({required String id}) async {
    final collection = await collectionRepo.getCollection(id: id);

    if (!collection.isPremium) {
      return true;
    }

    final storeId = _collectionStore(collection);

    final purchasedProductsList = await purchaseRepo.getPurchaseProducts();

    return purchasedProductsList.contains(storeId);
  }
}
