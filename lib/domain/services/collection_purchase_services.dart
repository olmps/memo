import 'dart:async';

import 'package:memo/core/env.dart';
import 'package:memo/data/repositories/collection_purchase_repository.dart';
import 'package:memo/data/repositories/collection_repository.dart';
import 'package:memo/domain/models/collection.dart';

abstract class CollectionPurchaseServices {
  /// Purchases the collection - from [id].
  Future<void> purchaseCollection({required String id});

  /// Verifies if the collection - from [id] - is visible to the user.
  Future<bool> isVisible({required String id});
}

class CollectionPurchaseServicesImpl implements CollectionPurchaseServices {
  CollectionPurchaseServicesImpl({
    required this.env,
    required this.collectionPurchaseRepo,
    required this.collectionRepo,
  });

  final EnvMetadata env;

  final CollectionPurchaseRepository collectionPurchaseRepo;

  final CollectionRepository collectionRepo;

  @override
  Future<void> purchaseCollection({required String id}) async {
    final collection = await collectionRepo.getCollection(id: id);

    await _purchaseInAppCollection(collection);
    await _updatePurchaseCollection(id: id, isPremium: false);
  }

  Future<void> _updatePurchaseCollection({required String id, required bool isPremium}) async {
    final collection = await collectionRepo.getCollection(id: id);
    final isPurchased = await collectionPurchaseRepo.getPurchasesInfo();

    if (isPurchased.contains(collection.appStoreId)) {
      await collectionPurchaseRepo.updatePurchaseCollection(id: id, isPremium: isPremium);
    }
  }

  Future<void> _purchaseInAppCollection(Collection collection) async {
    switch (env.platform) {
      case SupportedPlatform.ios:
        await collectionPurchaseRepo.purchaseInApp(storeId: collection.appStoreId);
        break;
      case SupportedPlatform.android:
        break;
    }
  }

  @override
  Future<bool> isVisible({required String id}) async {
    final collection = await collectionRepo.getCollection(id: id);

    if (collection.isPremium) {
      final isAvailable = await collectionPurchaseRepo.isAvailable();
      final isPurchased = await collectionPurchaseRepo.getPurchasesInfo();

      if (isAvailable.contains(collection.appStoreId)) {
        return !isPurchased.contains(collection.appStoreId);
      }
    }
    return collection.isPremium;
  }
}
