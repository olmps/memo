import 'package:memo/data/serializers/contributor_serializer.dart';
import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/collection.dart';

class CollectionKeys {
  static const id = 'id';
  static const name = 'name';
  static const description = 'description';
  static const category = 'category';
  static const tags = 'tags';
  static const uniqueMemosAmount = 'uniqueMemosAmount';
  static const uniqueMemoExecutionsAmount = 'uniqueMemoExecutionsAmount';
  static const executionsAmounts = 'executionsAmounts';
  static const timeSpentInMillis = 'timeSpentInMillis';
  static const contributors = 'contributors';
  static const isPremium = 'isPremium';
  static const appStoreId = 'appStoreId';
  static const playStoreId = 'playStoreId';
}

class CollectionSerializer implements Serializer<Collection, Map<String, dynamic>> {
  final contributorSerializer = ContributorSerializer();

  @override
  Collection from(Map<String, dynamic> json) {
    final id = json[CollectionKeys.id] as String;
    final name = json[CollectionKeys.name] as String;
    final description = json[CollectionKeys.description] as String;
    final category = json[CollectionKeys.category] as String;

    final rawTags = json[CollectionKeys.tags] as List;
    final tags = List<String>.from(rawTags);

    final uniqueMemosAmount = json[CollectionKeys.uniqueMemosAmount] as int;
    final uniqueMemoExecutionsAmount = json[CollectionKeys.uniqueMemoExecutionsAmount] as int?;

    final rawExecutionsAmounts = json[CollectionKeys.executionsAmounts] as Map<String, dynamic>?;
    final executionsAmounts =
        rawExecutionsAmounts?.map((key, dynamic value) => MapEntry(memoDifficultyFromRaw(key), value as int));

    final timeSpentInMillis = json[CollectionKeys.timeSpentInMillis] as int?;

    final rawContributors = List<Map<String, dynamic>>.from(json[CollectionKeys.contributors] as List);
    final contributors = rawContributors.map(contributorSerializer.from).toList();

    final isPremium = json[CollectionKeys.isPremium] as bool;

    final appStoreId = json[CollectionKeys.appStoreId] as String?;

    final playStoreId = json[CollectionKeys.playStoreId] as String?;

    return Collection(
      id: id,
      name: name,
      description: description,
      category: category,
      tags: tags,
      uniqueMemosAmount: uniqueMemosAmount,
      uniqueMemoExecutionsAmount: uniqueMemoExecutionsAmount ?? 0,
      executionsAmounts: executionsAmounts ?? {},
      timeSpentInMillis: timeSpentInMillis ?? 0,
      contributors: contributors,
      isPremium: isPremium,
      appStoreId: appStoreId ?? '',
      playStoreId: playStoreId ?? '',
    );
  }

  @override
  Map<String, dynamic> to(Collection collection) => <String, dynamic>{
        CollectionKeys.id: collection.id,
        CollectionKeys.name: collection.name,
        CollectionKeys.description: collection.description,
        CollectionKeys.category: collection.category,
        CollectionKeys.tags: collection.tags,
        CollectionKeys.uniqueMemosAmount: collection.uniqueMemosAmount,
        CollectionKeys.uniqueMemoExecutionsAmount: collection.uniqueMemoExecutionsAmount,
        CollectionKeys.executionsAmounts: collection.executionsAmounts.map((key, value) => MapEntry(key.raw, value)),
        CollectionKeys.contributors: collection.contributors.map(contributorSerializer.to),
        CollectionKeys.timeSpentInMillis: collection.timeSpentInMillis,
        CollectionKeys.isPremium: collection.isPremium,
        CollectionKeys.appStoreId: collection.appStoreId,
        CollectionKeys.playStoreId: collection.playStoreId,
      };
}
