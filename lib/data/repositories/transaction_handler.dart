import 'package:memo/data/gateways/database_transaction_handler.dart';
import 'package:memo/data/gateways/sembast_database.dart';

/// Allows multiple repositories to make atomic changes using a single transaction
abstract class TransactionHandler implements DatabaseTransactionHandler {}

class TransactionHandlerImpl implements TransactionHandler {
  TransactionHandlerImpl(this._db);

  final SembastDatabase _db;

  @override
  Future<void> runInTransaction(Future<void> Function() run) => _db.runInTransaction(run);
}
