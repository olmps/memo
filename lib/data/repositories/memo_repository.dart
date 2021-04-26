import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/memo_serializer.dart';
import 'package:memo/domain/models/memo.dart';

/// Handles all read, write and serialization operations pertaining to one or multiple [Memo]
abstract class MemoRepository {
  /// Retrieves all available [Memo] that belongs to a `Collection` with id [collectionId]
  Future<List<Memo>> getAllMemos({required String collectionId});

  /// Batch update a list of [memos]
  Future<void> updateMemos(List<Memo> memos);
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
  Future<void> updateMemos(List<Memo> memos) => _db.putAll(
        ids: memos.map((memo) => memo.id).toList(),
        objects: memos.map(_memoSerializer.to).toList(),
        store: _memoStore,
      );
}
