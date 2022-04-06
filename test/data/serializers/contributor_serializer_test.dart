import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/contributor_serializer.dart';
import 'package:memo/domain/models/collection.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = ContributorSerializer();
  const testContributor = Contributor(name: 'name');

  test('ContributorSerializer should correctly encode/decode a Contributor', () {
    final rawContributor = fixtures.contributor();

    final decodedCollection = serializer.from(rawContributor);
    expect(decodedCollection, testContributor);

    final encodedCollection = serializer.to(decodedCollection);
    expect(encodedCollection, rawContributor);
  });

  test('ContributorSerializer should fail to decode without required properties', () {
    expect(
      () {
        final rawContributor = fixtures.contributor()..remove(ContributorKeys.name);
        serializer.from(rawContributor);
      },
      throwsA(isA<TypeError>()),
    );
  });

  test('ContributorSerializer should decode with optional properties', () {
    final rawContributor = fixtures.contributor()
      ..[ContributorKeys.imageUrl] = 'url'
      ..[ContributorKeys.url] = 'url';

    final decodedContributor = serializer.from(rawContributor);

    const allPropsContributor = Contributor(name: 'name', imageUrl: 'url', url: 'url');

    expect(decodedContributor, allPropsContributor);
    expect(rawContributor, serializer.to(decodedContributor));
  });
}
