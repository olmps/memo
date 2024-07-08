import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/models/collection.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';
import 'package:memo/domain/models/product_info.dart';
import 'package:memo/domain/transients/collection_memos.dart';

void main() {
  CollectionMemos newCollectionMemos({
    List<MemoCollectionMetadata>? memosMetadata,
    List<Contributor>? contributors,
    ProductInfo? productInfo,
    int uniqueMemoExecutionsAmount = 0,
  }) {
    return CollectionMemos(
      id: 'id',
      name: 'name',
      description: 'description',
      category: 'category',
      tags: const [],
      isPremium: false,
      productInfo: productInfo ?? ProductInfo(price: 0.1, id: 'id'),
      contributors: contributors ?? const [Contributor(name: 'name')],
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

  test('CollectionMemos should not allow zero contributors', () {
    expect(
      () {
        newCollectionMemos(contributors: []);
      },
      throwsAssertionError,
    );
  });
}
