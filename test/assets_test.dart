import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/collection_memos_serializer.dart';
import 'package:memo/data/serializers/memo_collection_metadata_serializer.dart';
import 'package:memo/data/serializers/resource_serializer.dart';

import 'utils/asset_manifest.dart' as asset;

void main() {
  late final List<String> collectionsPaths;
  late final List<Map<String, dynamic>> collections;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final manifest = await asset.loadManifest();

    collectionsPaths = manifest.keys.where((key) => key.startsWith('assets/collections/')).toList();
    expect(collectionsPaths, isNotEmpty);

    final rawCollections = await Future.wait(collectionsPaths.map(rootBundle.loadString).toList());
    collections = rawCollections.map((raw) => jsonDecode(raw) as Map<String, dynamic>).toList();
  });

  test('Local collections assets should have at least one collection', () {
    expect(collectionsPaths, isNotEmpty);
  });

  test('Local collection assets should maintain its naming/id consistency', () {
    for (var index = 0; index < collectionsPaths.length; index++) {
      final collectionId = collections[index][CollectionMemosKeys.id] as String;
      final fullCollectionPath = collectionsPaths[index];

      expect(
        fullCollectionPath.contains('/$collectionId.json'),
        isTrue,
        reason: 'Collection had id "$collectionId" but file path "$fullCollectionPath"',
      );
    }
  });

  test('Local collection assets should have its unique ids amongst themselves', () {
    final collectionIds = <String>{};
    collections.forEach((collection) {
      final collectionId = collection[CollectionMemosKeys.id] as String;
      expect(collectionIds.contains(collectionId), isFalse, reason: 'Duplicate collection id "$collectionId"');
      collectionIds.add(collectionId);
    });
  });

  test('Local collections assets should have unique memo ids amongst themselves', () async {
    final memosIds = <String>{};
    for (final collection in collections) {
      List<Map<String, dynamic>>.from(
        collection[CollectionMemosKeys.memosMetadata] as List,
      ).forEach(
        (rawMemo) {
          final memoUniqueId = rawMemo[MemoCollectionMetadataKeys.uniqueId] as String;
          expect(
            memosIds.contains(memoUniqueId),
            isFalse,
            reason: 'Duplicate memo id "$memoUniqueId" in collection "$collection"',
          );
          memosIds.add(memoUniqueId);
        },
      );
    }
  });

  test('Resources assets should have unique memo ids amongst themselves', () async {
    final rawResourcesString = await rootBundle.loadString('assets/resources.json');
    final rawResources = List<Map<String, dynamic>>.from(jsonDecode(rawResourcesString) as List);

    final resourcesIds = <String>{};
    rawResources.forEach((rawResource) {
      final resourceId = rawResource[ResourceKeys.id] as String;
      expect(resourcesIds.contains(resourceId), isFalse, reason: 'Duplicate resource id "$resourceId"');
      resourcesIds.add(resourceId);
    });
  });
}
