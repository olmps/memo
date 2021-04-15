import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/models/collection.dart';

void main() {
  test('Collection should not allow invalid integers for its properties', () {
    expect(
      () {
        Collection(
          id: 'id',
          name: 'name',
          description: 'description',
          category: 'category',
          tags: const [],
          timeSpentInMillis: -1,
        );
      },
      throwsAssertionError,
    );

    expect(
      () {
        Collection(
          id: 'id',
          name: 'name',
          description: 'description',
          category: 'category',
          tags: const [],
          easyMemosAmount: -1,
        );
      },
      throwsAssertionError,
    );

    expect(
      () {
        Collection(
          id: 'id',
          name: 'name',
          description: 'description',
          category: 'category',
          tags: const [],
          mediumMemosAmount: -1,
        );
      },
      throwsAssertionError,
    );

    expect(
      () {
        Collection(
          id: 'id',
          name: 'name',
          description: 'description',
          category: 'category',
          tags: const [],
          hardMemosAmount: -1,
        );
      },
      throwsAssertionError,
    );
  });
}
