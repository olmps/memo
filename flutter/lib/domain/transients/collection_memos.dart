import 'package:equatable/equatable.dart';
import 'package:memo/domain/models/collection.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';

/// Groups a [CollectionMetadata] with its [memosMetadata].
///
/// This transient has a mutable behavior that allows updates to be made to [uniqueMemoExecutionsAmount].
class CollectionMemos extends CollectionMetadata with EquatableMixin {
  CollectionMemos({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    required this.contributors,
    required this.memosMetadata,
    int uniqueMemoExecutionsAmount = 0,
  })  : _uniqueMemoExecutionsAmount = uniqueMemoExecutionsAmount,
        assert(memosMetadata.isNotEmpty, 'must not be an empty list of memos'),
        assert(uniqueMemoExecutionsAmount >= 0, 'must be a positive (or zero) integer'),
        assert(contributors.isNotEmpty, 'must have at least one contributor');

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
  final List<Contributor> contributors;

  @override
  int get uniqueMemosAmount => memosMetadata.length;

  @override
  int get uniqueMemoExecutionsAmount => _uniqueMemoExecutionsAmount;
  int _uniqueMemoExecutionsAmount;

  void addToExecutionsAmount(int amount) {
    _uniqueMemoExecutionsAmount = _uniqueMemoExecutionsAmount + amount;

    assert(uniqueMemoExecutionsAmount >= 0, 'must be a positive (or zero) integer');
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        tags,
        contributors,
        _uniqueMemoExecutionsAmount,
        uniqueMemosAmount,
        memosMetadata,
      ];
}
