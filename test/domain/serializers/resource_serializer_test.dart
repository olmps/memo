import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/models/resource.dart';
import 'package:memo/domain/serializers/resource_serializer.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = ResourceSerializer();

  final testResource = Resource(
    id: '1',
    description: 'This is a good article!',
    tags: const ['Tag 1', 'Tag 2'],
    type: 'article',
    url: 'https://google.com/',
  );

  test('ResourceSerializer should correctly encode/decode a Resource', () {
    final rawResource = fixtures.resource();

    final decodedResource = serializer.fromMap(rawResource);
    expect(decodedResource, testResource);

    final encodedResource = serializer.mapOf(decodedResource);
    expect(encodedResource, rawResource);
  });

  test('ResourceSerializer should fail to decode without required properties', () {
    expect(() {
      final rawBlock = fixtures.resource()..remove('id');
      serializer.fromMap(rawBlock);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawBlock = fixtures.resource()..remove('description');
      serializer.fromMap(rawBlock);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawBlock = fixtures.resource()..remove('url');
      serializer.fromMap(rawBlock);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawBlock = fixtures.resource()..remove('tags');
      serializer.fromMap(rawBlock);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawBlock = fixtures.resource()..remove('type');
      serializer.fromMap(rawBlock);
    }, throwsA(isA<TypeError>()));
  });
}
