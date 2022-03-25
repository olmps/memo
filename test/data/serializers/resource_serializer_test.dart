import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/resource_serializer.dart';
import 'package:memo/domain/enums/resource_type.dart';
import 'package:memo/domain/models/resource.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = ResourceSerializer();

  final testResource = Resource(
    id: '1',
    description: 'This is a good article!',
    tags: const ['Tag 1', 'Tag 2'],
    type: ResourceType.article,
    url: 'https://google.com/',
  );

  test('ResourceSerializer should correctly encode/decode a Resource', () {
    final rawResource = fixtures.resource();

    final decodedResource = serializer.from(rawResource);
    expect(decodedResource, testResource);

    final encodedResource = serializer.to(decodedResource);
    expect(encodedResource, rawResource);
  });

  test('ResourceSerializer should fail to decode without required properties', () {
    expect(
      () {
        final rawBlock = fixtures.resource()..remove('id');
        serializer.from(rawBlock);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawBlock = fixtures.resource()..remove('description');
        serializer.from(rawBlock);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawBlock = fixtures.resource()..remove('url');
        serializer.from(rawBlock);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawBlock = fixtures.resource()..remove('tags');
        serializer.from(rawBlock);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawBlock = fixtures.resource()..remove('type');
        serializer.from(rawBlock);
      },
      throwsA(isA<TypeError>()),
    );
  });
}
