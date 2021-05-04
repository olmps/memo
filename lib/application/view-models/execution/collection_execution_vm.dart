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

final collectionExecutionVM = StateNotifierProvider.autoDispose.family<CollectionExecutionVM, String>(
  (ref, collectionId) => CollectionExecutionVMImpl(
    executionServices: ref.read(executionServices),
    collectionServices: ref.read(collectionServices),
    collectionId: collectionId,
  ),
);

abstract class CollectionExecutionVM extends StateNotifier<CollectionExecutionState> {
  CollectionExecutionVM(CollectionExecutionState state) : super(state);

  /// Marks the current [Memo] with the [difficulty]
  ///
  /// Always trigger a new [LoadedCollectionExecutionState] update with the selected [difficulty]
  ///
  /// Throws an [InconsistentStateError] if the state is other than [LoadedCollectionExecutionState]
  void markCurrentMemoDifficulty(MemoDifficulty difficulty);

  /// Go forward with the next suitable contents
  ///
  /// There are two scenarios where we should allow an execution to go forward:
  ///   1. there is a question being displayed and it should provide the answer for this question; or when
  ///   2. there is an answer contents being displayed, **with the according marked difficulty**, and it should proceed
  /// to next question (or change its state to a [FinishedCollectionExecutionState] if there are no more memos left). In
  /// this same case, if `nextContents` is requested while displaying an answer with no marked answer, it won't do
  /// anything.
  ///
  /// Throws an [InconsistentStateError] if the state is other than [LoadedCollectionExecutionState]
  Future<void> nextContents();
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
  void markCurrentMemoDifficulty(MemoDifficulty difficulty) {
    if (state is! LoadedCollectionExecutionState) {
      throw InconsistentStateError.viewModel('Cannot mark the current memo before finishing loading');
    }

    state = (state as LoadedCollectionExecutionState).copyWith(markedAnswer: difficulty);
  }

  @override
  Future<void> nextContents() async {
    if (state is! LoadedCollectionExecutionState) {
      throw InconsistentStateError.viewModel('Cannot request next memo contents before finishing loading');
    }

    final loadedState = state as LoadedCollectionExecutionState;

    // If there is a `markedAnswer`, we assume that this is a request to forward with the last marked difficulty
    if (loadedState.markedAnswer != null) {
      await _confirmMarkedMemo(loadedState.markedAnswer!);
    } else {
      // Otherwise, we expect it to be a request to display the question
      final currentMemo = _memos[_executions.length];
      state = loadedState.copyWith(isDisplayingQuestion: false, currentContents: currentMemo.rawAnswer);
    }
  }

  /// Makes the according updates to the internal control properties of an execution
  Future<void> _confirmMarkedMemo(MemoDifficulty answer) async {
    final currentMemo = _memos[_executions.length];

    final execution = MemoExecution(
      uniqueId: currentMemo.uniqueId,
      collectionId: collectionId,
      started: _currentMemoStartDate,
      finished: DateTime.now().toUtc(),
      rawQuestion: currentMemo.rawQuestion,
      rawAnswer: currentMemo.rawAnswer,
      markedDifficulty: answer,
    );
    _executions.add(execution);

    // If the `executions` update makes this `_isFinished` to true, we have to update this state to a
    // `FinishedCollectionExecutionState`
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
    } else {
      // Otherwise we proceed with the next available memo and start counting a new start date
      final completionValue = _executions.length / _memos.length;
      final nextMemo = _memos[_executions.length];

      state = LoadedCollectionExecutionState(
        isDisplayingQuestion: true,
        currentContents: nextMemo.rawQuestion,
        completionValue: completionValue,
        collectionName: _collection.name,
      );
      _currentMemoStartDate = DateTime.now().toUtc();
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
      isDisplayingQuestion: true,
      currentContents: _memos.first.rawQuestion,
      completionValue: 0,
      collectionName: _collection.name,
    );
  }
}

abstract class CollectionExecutionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadingCollectionExecutionState extends CollectionExecutionState {}

class LoadedCollectionExecutionState extends CollectionExecutionState {
  LoadedCollectionExecutionState({
    required this.isDisplayingQuestion,
    required this.currentContents,
    required this.completionValue,
    required this.collectionName,
    this.markedAnswer,
  });

  final String collectionName;

  final bool isDisplayingQuestion;
  final List<Map<String, dynamic>> currentContents;

  final MemoDifficulty? markedAnswer;

  /// A value ranging from `0` to `1` representing how close the user is to finishing the current execution
  final double completionValue;

  LoadedCollectionExecutionState copyWith({
    bool? isDisplayingQuestion,
    List<Map<String, dynamic>>? currentContents,
    double? completionValue,
    MemoDifficulty? markedAnswer,
  }) =>
      LoadedCollectionExecutionState(
        isDisplayingQuestion: isDisplayingQuestion ?? this.isDisplayingQuestion,
        currentContents: currentContents ?? this.currentContents,
        completionValue: completionValue ?? this.completionValue,
        markedAnswer: markedAnswer ?? this.markedAnswer,
        collectionName: collectionName,
      );

  @override
  List<Object?> get props => [collectionName, isDisplayingQuestion, currentContents, markedAnswer, completionValue];
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
