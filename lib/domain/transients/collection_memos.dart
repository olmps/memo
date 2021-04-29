import 'package:memo/domain/models/collection.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';

/// Groups a [CollectionMetadata] with its [memosMetadata]
///
/// This transient also have a mutable behavior through [addToExecutionsAmount], allowing updates to be made to
/// [uniqueMemoExecutionsAmount]
class CollectionMemos extends CollectionMetadata {
  CollectionMemos({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    required this.memosMetadata,
    int uniqueMemoExecutionsAmount = 0,
  })  : _uniqueMemoExecutionsAmount = uniqueMemoExecutionsAmount,
        assert(memosMetadata.isNotEmpty, 'Must not be an empty list of memos'),
        assert(uniqueMemoExecutionsAmount >= 0, 'must be a positive (or zero) integer');

  final List<MemoCollectionMetadata> memosMetadata;

  @override
  final String id;

  @override
  final String name;

  @override
  final String description;

  @override
  final String category;

  @override
  final List<String> tags;

  @override
  int get uniqueMemosAmount => memosMetadata.length;

  @override
  int get uniqueMemoExecutionsAmount => _uniqueMemoExecutionsAmount;
  int _uniqueMemoExecutionsAmount;

  void addToExecutionsAmount(int amount) {
    _uniqueMemoExecutionsAmount = _uniqueMemoExecutionsAmount + amount;

    assert(uniqueMemoExecutionsAmount >= 0, 'must be a positive (or zero) integer');
  }
}
