import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/memo_serializer.dart';
import 'package:memo/domain/models/memo.dart';

/// Handles all read, write and serialization operations pertaining to one or multiple [Memo]
abstract class MemoRepository {
  /// Retrieves all available [Memo] that belongs to a `Collection` with id [collectionId]
  Future<List<Memo>> getAllMemos({required String collectionId});

  /// Retrieves all available [Memo] that belongs to any of the `Collection`s with [collectionIds]
  Future<List<Memo>> getAllMemosByAnyCollectionId({required List<String> collectionIds});

  /// Batch put a list of [memos]
  ///
  /// If [updatesOnlyCollectionMetadata] is `true`, updates only those properties related to the
  /// `MemoCollectionMetadata`.
  Future<void> putMemos(List<Memo> memos, {required bool updatesOnlyCollectionMetadata});

  /// Batch remove a list of memos by its respective [ids]
  Future<void> removeMemosByIds(List<String> ids);

  /// Retrieves a list of memos by its respective [ids]
  Future<List<Memo?>> getMemosByIds(List<String> ids);
}

class MemoRepositoryImpl implements MemoRepository {
  MemoRepositoryImpl(this._db);

  final SembastDatabase _db;
  final _memoSerializer = MemoSerializer();
  final _memoStore = 'memos';

  @override
  Future<List<Memo>> getAllMemos({required String collectionId}) async {
    final finder = Finder(filter: Filter.equals(MemoKeys.collectionId, collectionId));

    final rawMemos = await _db.getAll(store: _memoStore, finder: finder);
    return rawMemos.map(_memoSerializer.from).toList();
  }

  @override
  Future<List<Memo>> getAllMemosByAnyCollectionId({required List<String> collectionIds}) async {
    final finder = Finder(filter: Filter.inList(MemoKeys.collectionId, collectionIds));

    final rawMemos = await _db.getAll(store: _memoStore, finder: finder);
    return rawMemos.map(_memoSerializer.from).toList();
  }

  @override
  Future<void> putMemos(List<Memo> memos, {required bool updatesOnlyCollectionMetadata}) async {
    if (updatesOnlyCollectionMetadata) {
      return _db.putAll(
        ids: memos.map((memo) => memo.uniqueId).toList(),
        objects: memos
            .map(
              (memo) => {
                MemoKeys.uniqueId: memo.uniqueId,
                MemoKeys.collectionId: memo.collectionId,
                MemoKeys.rawQuestion: memo.rawQuestion,
                MemoKeys.rawAnswer: memo.rawAnswer,
              },
            )
            .toList(),
        store: _memoStore,
      );
    } else {
      return _db.putAll(
        ids: memos.map((memo) => memo.uniqueId).toList(),
        objects: memos.map(_memoSerializer.to).toList(),
        store: _memoStore,
      );
    }
  }

  @override
  Future<void> removeMemosByIds(List<String> ids) => _db.removeAll(ids: ids, store: _memoStore);

  @override
  Future<List<Memo?>> getMemosByIds(List<String> ids) async {
    final rawMemos = await _db.getAllByIds(ids: ids, store: _memoStore);
    return rawMemos.map((rawMemo) => rawMemo != null ? _memoSerializer.from(rawMemo) : null).toList();
  }
}
