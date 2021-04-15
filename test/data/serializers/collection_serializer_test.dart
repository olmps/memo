import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/collection_serializer.dart';
import 'package:memo/domain/models/collection.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = CollectionSerializer();
  const testCollection = Collection(
    id: '1',
    name: 'My Collection',
    description: 'This collection represents a collection.',
    category: 'Category',
    tags: ['Tag 1', 'Tag 2'],
  );

  test('CollectionSerializer should correctly encode/decode a Collection', () {
    final rawCollection = fixtures.collection();

    final decodedCollection = serializer.from(rawCollection);
    expect(decodedCollection, testCollection);

    final encodedCollection = serializer.to(decodedCollection);
    expect(encodedCollection, rawCollection);
  });

  test('CollectionSerializer should fail to decode without required properties', () {
    expect(() {
      final rawCollection = fixtures.collection()..remove('id');
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtures.collection()..remove('name');
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtures.collection()..remove('description');
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtures.collection()..remove('category');
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtures.collection()..remove('tags');
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtures.collection()..remove('timeSpentInMillis');
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtures.collection()..remove('easyMemosAmount');
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtures.collection()..remove('mediumMemosAmount');
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtures.collection()..remove('hardMemosAmount');
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
  });
}
