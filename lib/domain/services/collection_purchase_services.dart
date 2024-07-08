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

  /// Compares all file-based collections (`CollectionMemos`) with collections stored in the user database (`Collection`).
  ///
  /// Updates purchased collections based on the RevenueCat backend.
  Future<void> updatePurchasesIfNeeded();
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

    if (isPurchased.contains(collection.productInfo.id)) {
      await purchaseRepo.updatePurchase(purchaseId: collection.productInfo.id);
    }
  }

  Future<void> _purchaseInAppCollection(Collection collection) async {
    await purchaseRepo.purchaseInApp(storeId: collection.productInfo.id);
  }

  @override
  Future<bool> isPurchased({required String id}) async {
    final collection = await collectionRepo.getCollection(id: id);

    if (!collection.isPremium) {
      return true;
    }

    final storeId = collection.productInfo.id;

    final purchasedProductsList = await purchaseRepo.getPurchaseProducts();

    return purchasedProductsList.contains(storeId);
  }

  @override
  Future<void> updatePurchasesIfNeeded() async {
    final collections = await collectionRepo.getAllCollectionMemos();

    for (final collection in collections) {
      await _updatePurchaseCollection(id: collection.id);
    }
  }
}
