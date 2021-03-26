import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/models/deck.dart';

void main() {
  test('Deck should not allow invalid integers for its properties', () {
    expect(
      () {
        Deck(
          id: 'id',
          name: 'name',
          description: 'description',
          category: 'category',
          tags: const [],
          timeSpentInMillis: -1,
        );
      },
      throwsA(isA<AssertionError>()),
    );

    expect(
      () {
        Deck(
          id: 'id',
          name: 'name',
          description: 'description',
          category: 'category',
          tags: const [],
          easyCardsAmount: -1,
        );
      },
      throwsA(isA<AssertionError>()),
    );

    expect(
      () {
        Deck(
          id: 'id',
          name: 'name',
          description: 'description',
          category: 'category',
          tags: const [],
          mediumCardsAmount: -1,
        );
      },
      throwsA(isA<AssertionError>()),
    );

    expect(
      () {
        Deck(
          id: 'id',
          name: 'name',
          description: 'description',
          category: 'category',
          tags: const [],
          hardCardsAmount: -1,
        );
      },
      throwsA(isA<AssertionError>()),
    );
  });
}
