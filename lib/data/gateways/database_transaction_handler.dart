abstract class DatabaseTransactionHandler {
  /// Handles all changes made inside [run] as a single atomic operation
  Future<void> runInTransaction(Future<void> Function() run);
}
