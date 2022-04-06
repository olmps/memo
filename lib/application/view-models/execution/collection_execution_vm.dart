import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/view-models/app_vm.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/collection.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:memo/domain/services/collection_services.dart';
import 'package:memo/domain/services/execution_services.dart';

final collectionExecutionVM =
    StateNotifierProvider.autoDispose.family<CollectionExecutionVM, CollectionExecutionState, String>(
  (ref, collectionId) => CollectionExecutionVMImpl(
    executionServices: ref.read(executionServices),
    collectionServices: ref.read(collectionServices),
    collectionId: collectionId,
  ),
);

abstract class CollectionExecutionVM extends StateNotifier<CollectionExecutionState> {
  CollectionExecutionVM(CollectionExecutionState state) : super(state);

  /// Marks the current [Memo] with the [difficulty].
  ///
  /// If the current execution still has more memos to be executed, returns the next one in the stack. When there are no
  /// more memos left, returns `null` and updates the state to [FinishedCollectionExecutionState].
  ///
  /// Throws an [InconsistentStateError] if the state is other than [LoadedCollectionExecutionState].
  Future<MemoMetadata?> markCurrentMemoDifficulty(MemoDifficulty difficulty);
}

class CollectionExecutionVMImpl extends CollectionExecutionVM {
  CollectionExecutionVMImpl({
    required this.executionServices,
    required this.collectionServices,
    required this.collectionId,
  }) : super(LoadingCollectionExecutionState()) {
    _loadMemos();
  }

  final String collectionId;
  final ExecutionServices executionServices;
  final CollectionServices collectionServices;

  late final List<Memo> _memos;
  late final Collection _collection;
  final _executions = <MemoExecution>[];
  var _currentMemoStartDate = DateTime.now().toUtc();

  bool get _isFinished => _memos.length == _executions.length;

  @override
  Future<MemoMetadata?> markCurrentMemoDifficulty(MemoDifficulty difficulty) async {
    if (state is! LoadedCollectionExecutionState) {
      throw InconsistentStateError.viewModel('Cannot request next memo contents before finishing loading');
    }

    final currentMemo = _memos[_executions.length];

    final execution = MemoExecution(
      uniqueId: currentMemo.uniqueId,
      collectionId: collectionId,
      started: _currentMemoStartDate,
      finished: DateTime.now().toUtc(),
      rawQuestion: currentMemo.rawQuestion,
      rawAnswer: currentMemo.rawAnswer,
      markedDifficulty: difficulty,
    );
    _executions.add(execution);

    // If the `executions` update makes this `_isFinished` to true, we have to update this state to a
    // `FinishedCollectionExecutionState`.
    if (_isFinished) {
      state = LoadingCollectionExecutionState();
      await executionServices.addExecutions(_executions, collectionId: collectionId);

      final mappedExecutions = <MemoDifficulty, int>{
        for (final difficulty in MemoDifficulty.values) difficulty: 0,
      };

      _executions.forEach((execution) {
        final difficultyValue = mappedExecutions[execution.markedDifficulty];
        mappedExecutions[execution.markedDifficulty] = difficultyValue! + 1;
      });

      final updatedCollection = await collectionServices.getCollectionById(collectionId);
      if (updatedCollection.isCompleted) {
        final memoryRecall = await collectionServices.getCollectionMemoryRecall(collectionId: collectionId);
        state = FinishedCompleteCollectionExecutionState(
          mappedExecutions,
          collectionName: updatedCollection.name,
          recallLevel: memoryRecall,
        );
      } else {
        state = FinishedIncompleteCollectionExecutionState(
          mappedExecutions,
          collectionName: updatedCollection.name,
          uniqueExecutedMemos: updatedCollection.uniqueMemoExecutionsAmount,
          totalUniqueMemos: updatedCollection.uniqueMemosAmount,
        );
      }

      return null;
    } else {
      // Otherwise we proceed with the next available memo and start counting a new start date.
      final completionValue = _executions.length / _memos.length;

      final loadedState = state as LoadedCollectionExecutionState;
      state = loadedState.copyWith(completionValue: completionValue);
      _currentMemoStartDate = DateTime.now().toUtc();

      final nextMemo = _memos[_executions.length];
      return MemoMetadata(question: nextMemo.rawQuestion, answer: nextMemo.rawAnswer);
    }
  }

  Future<void> _loadMemos() async {
    final futures = await Future.wait([
      collectionServices.getCollectionById(collectionId),
      executionServices.getNextExecutableMemosChunk(collectionId: collectionId),
    ]);

    _collection = futures[0] as Collection;
    _memos = futures[1] as List<Memo>;
    state = LoadedCollectionExecutionState(
      initialMemo: MemoMetadata(question: _memos.first.rawQuestion, answer: _memos.first.rawAnswer),
      completionValue: 0,
      collectionName: _collection.name,
    );
  }
}

typedef RawMemoContents = List<Map<String, dynamic>>;

class MemoMetadata extends Equatable {
  const MemoMetadata({required this.question, required this.answer});

  final RawMemoContents question;
  final RawMemoContents answer;

  @override
  List<Object?> get props => [question, answer];
}

abstract class CollectionExecutionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadingCollectionExecutionState extends CollectionExecutionState {}

class LoadedCollectionExecutionState extends CollectionExecutionState {
  LoadedCollectionExecutionState({
    required this.initialMemo,
    required this.completionValue,
    required this.collectionName,
  });

  final String collectionName;
  final MemoMetadata initialMemo;

  /// A value ranging from `0` to `1` representing how close the user is to finishing the current execution.
  final double completionValue;

  LoadedCollectionExecutionState copyWith({double? completionValue}) => LoadedCollectionExecutionState(
        initialMemo: initialMemo,
        completionValue: completionValue ?? this.completionValue,
        collectionName: collectionName,
      );

  @override
  List<Object?> get props => [collectionName, initialMemo, completionValue];
}

abstract class FinishedCollectionExecutionState extends CollectionExecutionState {
  FinishedCollectionExecutionState(this._executions, {required this.collectionName});

  final Map<MemoDifficulty, int> _executions;
  List<MemoDifficulty> get availableDifficulties => _executions.keys.toList();
  final String collectionName;

  int get totalExecutions => _executions.values.reduce((value, element) => value + element);
  double progressValueForDifficulty(MemoDifficulty difficulty) => _executions[difficulty]! / totalExecutions;
  String readableProgressForDifficulty(MemoDifficulty difficulty) =>
      (progressValueForDifficulty(difficulty) * 100).round().toString();

  @override
  List<Object?> get props => [_executions, collectionName];
}

class FinishedIncompleteCollectionExecutionState extends FinishedCollectionExecutionState {
  FinishedIncompleteCollectionExecutionState(
    Map<MemoDifficulty, int> executions, {
    required String collectionName,
    required this.uniqueExecutedMemos,
    required this.totalUniqueMemos,
  }) : super(executions, collectionName: collectionName);

  final int uniqueExecutedMemos;
  final int totalUniqueMemos;

  double get completionLevel => uniqueExecutedMemos / totalUniqueMemos;
  String get readableCompletion => (completionLevel * 100).round().toString();

  @override
  List<Object?> get props => [uniqueExecutedMemos, totalUniqueMemos, ...super.props];
}

class FinishedCompleteCollectionExecutionState extends FinishedCollectionExecutionState {
  FinishedCompleteCollectionExecutionState(
    Map<MemoDifficulty, int> executions, {
    required String collectionName,
    required this.recallLevel,
  }) : super(executions, collectionName: collectionName);

  final double recallLevel;
  String get readableRecall => (recallLevel * 100).round().toString();

  @override
  List<Object?> get props => [recallLevel, ...super.props];
}
