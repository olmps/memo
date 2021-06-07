import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/models/contributor.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';
import 'package:memo/domain/transients/collection_memos.dart';

void main() {
  CollectionMemos newCollectionMemos({
    List<MemoCollectionMetadata>? memosMetadata,
    int uniqueMemoExecutionsAmount = 0,
  }) {
    return CollectionMemos(
      id: 'id',
      name: 'name',
      description: 'description',
      category: 'category',
      contributors: const [
      Contributor(
        id: '03a5f9b4-b424-4010-8027-1ef22c748g56',
        name: '@lucasbiancogs',
        imageUrl: 'https://avatars.githubusercontent.com/u/64819163?s=400&u=3ca78fee7808f7b5b7ad8e9230e268519e9aea71&v=4',
        url: 'https://github.com/lucasbiancogs'
      )
    ],
      tags: const [],
      memosMetadata:
          memosMetadata ?? [MemoCollectionMetadata(uniqueId: '1', rawAnswer: const [], rawQuestion: const [])],
      uniqueMemoExecutionsAmount: uniqueMemoExecutionsAmount,
    );
  }

  test('CollectionMemos should not allow an empty list of memos metadata', () {
    expect(
      () {
        newCollectionMemos(memosMetadata: []);
      },
      throwsAssertionError,
    );
  });

  test('CollectionMemos should not allow a negative amount of unique executions', () {
    expect(
      () {
        newCollectionMemos(uniqueMemoExecutionsAmount: -1);
      },
      throwsAssertionError,
    );
  });

  test('CollectionMemos should not allow a updating the unique executions to a negative number', () {
    expect(
      () {
        newCollectionMemos().addToExecutionsAmount(-1);
      },
      throwsAssertionError,
    );
  });
}
