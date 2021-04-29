import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/memo_execution_serializer.dart';
import 'package:memo/domain/models/memo_execution.dart';

/// Handles all read, write and serialization operations pertaining to one or multiple [MemoExecution]
abstract class MemoExecutionRepository {
  /// Batch-create a list of [executions]
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
