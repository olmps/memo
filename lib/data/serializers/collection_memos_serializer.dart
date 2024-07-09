import 'package:memo/data/serializers/contributor_serializer.dart';
import 'package:memo/data/serializers/memo_collection_metadata_serializer.dart';
import 'package:memo/data/serializers/product_info_serializer.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/transients/collection_memos.dart';

class CollectionMemosKeys {
  static const id = 'id';
  static const name = 'name';
  static const description = 'description';
  static const category = 'category';
  static const contributors = 'contributors';
  static const tags = 'tags';
  static const memosMetadata = 'memos';
  static const isPremium = 'isPremium';
  static const productInfo = 'productInfo';
}

class CollectionMemosSerializer implements Serializer<CollectionMemos, Map<String, dynamic>> {
  final memoMetadataSerializer = MemoCollectionMetadataSerializer();
  final contributorSerializer = ContributorSerializer();
  final productInfoSerializer = ProductInfoSerializer();

  @override
  CollectionMemos from(Map<String, dynamic> json) {
    final id = json[CollectionMemosKeys.id] as String;
    final name = json[CollectionMemosKeys.name] as String;
    final description = json[CollectionMemosKeys.description] as String;
    final category = json[CollectionMemosKeys.category] as String;
    final isPremium = json[CollectionMemosKeys.isPremium] as bool?;

    final rawProductInfo = json[CollectionMemosKeys.productInfo] as Map<String, dynamic>?;
    final productInfo = rawProductInfo != null ? productInfoSerializer.from(rawProductInfo) : null;

    final tags = List<String>.from(json[CollectionMemosKeys.tags] as List);

    final rawMemos = List<Map<String, dynamic>>.from(json[CollectionMemosKeys.memosMetadata] as List);
    final memosMetadata = rawMemos.map(memoMetadataSerializer.from).toList();

    final rawContributors = List<Map<String, dynamic>>.from(json[CollectionMemosKeys.contributors] as List);
    final contributors = rawContributors.map(contributorSerializer.from).toList();

    return CollectionMemos(
      id: id,
      name: name,
      description: description,
      category: category,
      tags: tags,
      memosMetadata: memosMetadata,
      contributors: contributors,
      isPremium: isPremium ?? false,
      productInfo: productInfo,
    );
  }

  @override
  Map<String, dynamic> to(CollectionMemos collection) => <String, dynamic>{
        CollectionMemosKeys.id: collection.id,
        CollectionMemosKeys.name: collection.name,
        CollectionMemosKeys.description: collection.description,
        CollectionMemosKeys.category: collection.category,
        CollectionMemosKeys.tags: collection.tags,
        CollectionMemosKeys.memosMetadata: collection.memosMetadata.map(memoMetadataSerializer.to).toList(),
        CollectionMemosKeys.contributors: collection.contributors.map(contributorSerializer.to).toList(),
        CollectionMemosKeys.isPremium: collection.isPremium,
        if (collection.isPremium) CollectionMemosKeys.productInfo: productInfoSerializer.to(collection.productInfo!),
      };
}
