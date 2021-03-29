import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/enums/resource_type.dart';
import 'package:memo/domain/models/resource.dart';

void main() {
  test('Deck should not allow empty tags', () {
    expect(
      () {
        Resource(id: 'id', description: 'description', tags: const [], type: ResourceType.article, url: 'url');
      },
      throwsA(isA<AssertionError>()),
    );
  });
}
