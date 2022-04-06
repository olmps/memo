import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/collection_serializer.dart';
import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/collection.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = CollectionSerializer();
  final testCollection = Collection(
    id: '1',
    name: 'My Collection',
    description: 'This collection represents a collection.',
    category: 'Category',
    contributors: const [Contributor(name: 'name')],
    tags: const ['Tag 1', 'Tag 2'],
    uniqueMemosAmount: 1,
  );

  Map<String, dynamic> completeFixture() =>
      fixtures.collection()..[CollectionKeys.contributors] = [fixtures.contributor()];

  test('CollectionSerializer should correctly encode/decode a Collection', () {
    final rawCollection = completeFixture();

    final decodedCollection = serializer.from(rawCollection);
    expect(decodedCollection, testCollection);

    final encodedCollection = serializer.to(decodedCollection);
    expect(encodedCollection, rawCollection);
  });

  test('CollectionSerializer should fail to decode without required properties', () {
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionKeys.id);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionKeys.name);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionKeys.description);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionKeys.category);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionKeys.tags);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionKeys.contributors);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionKeys.uniqueMemosAmount);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
  });

  test('CollectionSerializer should decode with optional properties', () {
    final rawCollection = completeFixture()
      ..[CollectionKeys.uniqueMemoExecutionsAmount] = 1
      ..[CollectionKeys.executionsAmounts] = {
        MemoDifficulty.easy.raw: 1,
        MemoDifficulty.medium.raw: 0,
        MemoDifficulty.hard.raw: 0
      }
      ..[CollectionKeys.timeSpentInMillis] = 5000;

    final decodedCollection = serializer.from(rawCollection);

    final allPropsCollection = Collection(
      id: '1',
      name: 'My Collection',
      description: 'This collection represents a collection.',
      category: 'Category',
      contributors: const [Contributor(name: 'name')],
      tags: const ['Tag 1', 'Tag 2'],
      uniqueMemosAmount: 1,
      uniqueMemoExecutionsAmount: 1,
      executionsAmounts: const {MemoDifficulty.easy: 1},
      timeSpentInMillis: 5000,
    );

    expect(decodedCollection, allPropsCollection);
    expect(rawCollection, serializer.to(decodedCollection));
  });
}
