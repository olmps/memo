import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/memo_execution_serializer.dart';
import 'package:memo/domain/models/memo_execution.dart';

/// Handles all IO and serialization operations associated with [MemoExecution]s.
abstract class MemoExecutionRepository {
  /// Creates a list of [executions].
  Future<void> addExecutions(List<MemoExecution> executions);
}

class MemoExecutionRepositoryImpl implements MemoExecutionRepository {
  MemoExecutionRepositoryImpl(this._db);

  final SembastDatabase _db;
  final _memoExecutionsSerializer = MemoExecutionSerializer();
  final _memoExecutionsStore = 'memo_executions';

  @override
  Future<void> addExecutions(List<MemoExecution> executions) {
    final ids = executions.map((exec) => exec.uniqueId).toList();
    final encodedExecutions = executions.map(_memoExecutionsSerializer.to).toList();
    return _db.putAll(ids: ids, objects: encodedExecutions, store: _memoExecutionsStore);
  }
}
