import 'package:memo/data/repositories/collection_repository.dart';
import 'package:memo/data/repositories/memo_execution_repository.dart';
import 'package:memo/data/repositories/memo_repository.dart';
import 'package:memo/data/repositories/user_repository.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/isolated_services/memory_recall_services.dart';
import 'package:memo/domain/models/collection.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:memo/domain/models/memo_execution.dart';

/// Handles all domain-specific operations pertaining to the act of executing a [Collection] and its [Memo]s
abstract class ExecutionServices {
  /// Retrieves a suitable chunk of [Memo]s before an execution session of the [Collection] of [collectionId]
  ///
  /// To retrieve this chunk, it first sorts all the [Memo]s belonging to the referenced [Collection] by memoryRecall
  /// (also, if they are pristine, they take priority), and then chunks it using the execution chunk setting given the
  /// current `User`.
  Future<List<Memo>> getNextExecutableMemosChunk({required String collectionId});

  /// Adds new [executions] to be associated with all of the application's dependencies
  ///
  /// When adding a new list of [executions] - for the following [Collection] of [collectionId] -, multiple dependencies
  /// (or locations) are required to be updated with this new metadata:
  ///   - an `User`, that holds the "application-wide" stats for executions;
  ///   - a `Collection`, that holds the "collection-wide" stats for executions;
  ///   - the respective `Memo`s that were executed, also with the individual stats for each respective execution; and
  ///   - a list of `MemoExecution`s that serves as plain history for these [executions].
  Future<void> addExecutions(List<MemoExecution> executions, {required String collectionId});
}

class ExecutionServicesImpl implements ExecutionServices {
  ExecutionServicesImpl({
    required this.userRepo,
    required this.memoRepo,
    required this.collectionRepo,
    required this.executionsRepo,
    required this.memoryServices,
  });

  final UserRepository userRepo;
  final MemoRepository memoRepo;
  final MemoExecutionRepository executionsRepo;
  final CollectionRepository collectionRepo;

  final MemoryRecallServices memoryServices;

  @override
  Future<List<Memo>> getNextExecutableMemosChunk({required String collectionId}) async {
    final user = await userRepo.getUser();
    final chunkGoal = user!.memosExecutionChunkGoal;

    final allCollectionMemos = await memoRepo.getAllMemos(collectionId: collectionId);
    final pristineMemos = <Memo>[];
    final executedMemos = <Memo>[];

    // Segment the memos by pristine/not-pristine, as the former takes priority
    allCollectionMemos.forEach((memo) {
      if (memo.isPristine) {
        pristineMemos.add(memo);
      } else {
        executedMemos.add(memo);
      }
    });

    // If we have enough pristine memos, we don't need to calculate each memory recall
    if (pristineMemos.length >= chunkGoal) {
      return pristineMemos.sublist(0, chunkGoal);
    }

    final executedMemoPerRecall =
        // We can use the bang operator here because all executedMemos surely are not pristine, which is the only condition
        // that the evaluation returns `null`
        executedMemos.asMap().map((key, value) => MapEntry(memoryServices.evaluateMemoryRecall(value)!, value));

    final sortedRecallKeys = executedMemoPerRecall.keys.toList()
      ..sort((recallA, recallB) => recallA.compareTo(recallB));

    // Otherwise we start with all the existing pristine memos and keep adding the remaining sorted-by-recall memos
    // until the chunk has met its required size (or if there are no more memos to be added)
    final executableMemosChunk = pristineMemos;
    while (chunkGoal > executableMemosChunk.length && executedMemoPerRecall.isNotEmpty) {
      final lessRecalledMemoKey = sortedRecallKeys.first;
      executableMemosChunk.add(executedMemoPerRecall[lessRecalledMemoKey]!);

      executedMemoPerRecall.remove(lessRecalledMemoKey);
      sortedRecallKeys.removeAt(0);
    }

    return executableMemosChunk;
  }

  @override
  Future<void> addExecutions(List<MemoExecution> executions, {required String collectionId}) async {
    final associatedData = await Future.wait<dynamic>([
      memoRepo.getAllMemos(collectionId: collectionId),
      userRepo.getUser(),
      collectionRepo.getCollection(id: collectionId),
    ]);

    var totalTimeSpent = 0;
    var newUniqueMemos = 0;
    final executionsAmounts = <MemoDifficulty, int>{};
    final updatedMemos = <Memo>[];

    final allCollectionMemos = associatedData[0] as List<Memo>;
    executions.forEach((execution) {
      totalTimeSpent += execution.timeSpentInMillis;

      // Creates a copy of the memo associated with this execution (same id) and with the new execution-related
      // properties
      final associatedMemo = allCollectionMemos.firstWhere((memo) => memo.uniqueId == execution.uniqueId);
      final associatedMemoExecutionAmounts = associatedMemo.executionsAmounts;
      final memoCurrentValue = associatedMemoExecutionAmounts[execution.markedDifficulty] ?? 0;
      associatedMemoExecutionAmounts[execution.markedDifficulty] = memoCurrentValue + 1;
      final updatedMemo = associatedMemo.copyWith(
        lastExecution: execution,
        executionsAmounts: associatedMemoExecutionAmounts,
        timeSpentInMillis: associatedMemo.timeSpentInMillis + execution.timeSpentInMillis,
      );
      updatedMemos.add(updatedMemo);

      // Update the unique count if this memo has never been executed before
      if (associatedMemo.isPristine) {
        newUniqueMemos++;
      }

      // Update the total count for the specific difficulty execution
      final totalExecutionsDifficultyAmount = executionsAmounts[execution.markedDifficulty] ?? 0;
      executionsAmounts[execution.markedDifficulty] = totalExecutionsDifficultyAmount + 1;
    });

    final userMetadata = associatedData[1] as MemoExecutionsMetadata;
    final associatedCollection = associatedData[2] as Collection;
    final userUpdatedExecutions = userMetadata.executionsAmounts;
    final collectionUpdatedExecutions = associatedCollection.executionsAmounts;

    // Uses the `executionsAmounts` to get the updated `executionsAmount` for the user and the associated collection
    executionsAmounts.forEach((key, value) {
      final userCurrentValue = userUpdatedExecutions[key] ?? 0;
      userUpdatedExecutions[key] = userCurrentValue + value;

      final collectionCurrentValue = collectionUpdatedExecutions[key] ?? 0;
      collectionUpdatedExecutions[key] = collectionCurrentValue + value;
    });

    // Dispatch all updates simultaneously
    await Future.wait([
      executionsRepo.addExecutions(executions),
      userRepo.updateExecution(
        executionsAmounts: userUpdatedExecutions,
        timeSpentInMillis: userMetadata.timeSpentInMillis + totalTimeSpent,
      ),
      collectionRepo.updateExecution(
        id: collectionId,
        executionsAmounts: collectionUpdatedExecutions,
        timeSpentInMillis: associatedCollection.timeSpentInMillis + totalTimeSpent,
        uniqueExecutionsAmount: associatedCollection.uniqueMemoExecutionsAmount + newUniqueMemos,
      ),
      memoRepo.putMemos(updatedMemos, updatesOnlyCollectionMetadata: false),
    ]);
  }
}
