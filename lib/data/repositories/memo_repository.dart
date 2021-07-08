import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/memo_serializer.dart';
import 'package:memo/domain/models/memo.dart';

/// Handles all IO and serialization operations associated with [Memo]s.
abstract class MemoRepository {
  /// Retrieves all [Memo]s that have their [Memo.collectionId] set to [collectionId].
  Future<List<Memo>> getAllMemos({required String collectionId});

  /// Retrieves all [Memo]s that have their [Memo.collectionId] set to any of the [collectionIds].
  Future<List<Memo>> getAllMemosByAnyCollectionId({required List<String> collectionIds});

  /// Puts a list of [memos].
  ///
  /// If [updatesOnlyCollectionMetadata] is `true`, updates only those properties related to `MemoCollectionMetadata`.
  Future<void> putMemos(List<Memo> memos, {required bool updatesOnlyCollectionMetadata});

  /// Removes a list of memos by their respective [ids].
  Future<void> removeMemosByIds(List<String> ids);

  /// Retrieves a list of memos by their respective [ids].
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
