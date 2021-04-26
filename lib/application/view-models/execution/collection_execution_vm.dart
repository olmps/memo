import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/view-models/app_vm.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:memo/domain/services/execution_services.dart';

final collectionExecutionVM = StateNotifierProvider.autoDispose.family<CollectionExecutionVM, String>(
    (ref, collectionId) => CollectionExecutionVMImpl(ref.read(executionServices), collectionId: collectionId));

abstract class CollectionExecutionVM extends StateNotifier<CollectionExecutionState> {
  CollectionExecutionVM(CollectionExecutionState state) : super(state);

  /// Marks the current [Memo] with the [difficulty]
  ///
  /// This mark will always trigger a new [LoadedCollectionExecutionState] update with the next [Memo] and, if there are
  /// no more [Memo]s, the new state should be a [FinishedCollectionExecutionState].
  Future<void> markCurrentMemoDifficulty(MemoDifficulty difficulty);
}

class CollectionExecutionVMImpl extends CollectionExecutionVM {
  CollectionExecutionVMImpl(this._services, {required this.collectionId}) : super(LoadingCollectionExecutionState()) {
    _loadMemos();
  }

  final String collectionId;
  final ExecutionServices _services;

  late final List<Memo> _memos;
  final _executions = <MemoExecution>[];
  var _currentMemoStartDate = DateTime.now().toUtc();

  bool get _isFinished => _memos.length == _executions.length;

  @override
  Future<void> markCurrentMemoDifficulty(MemoDifficulty difficulty) async {
    if (state is! LoadedCollectionExecutionState) {
      throw InconsistentStateError.viewModel('Cannot mark the current memo before finishing loading');
    }

    final loadedState = state as LoadedCollectionExecutionState;

    final execution = MemoExecution(
      memoId: loadedState._currentMemo.id,
      collectionId: collectionId,
      started: _currentMemoStartDate,
      finished: DateTime.now().toUtc(),
      rawQuestion: loadedState.rawQuestion,
      rawAnswer: loadedState.rawAnswer,
      markedDifficulty: difficulty,
    );
    _executions.add(execution);

    if (_isFinished) {
      state = LoadingCollectionExecutionState();
      await _services.addExecutions(_executions, collectionId: collectionId);
      state = FinishedCollectionExecutionState();
    } else {
      final completionValue = _executions.length / _memos.length;
      final nextMemo = _memos[_executions.length];
      state = LoadedCollectionExecutionState(nextMemo, completionValue: completionValue);
      _currentMemoStartDate = DateTime.now().toUtc();
    }
  }

  Future<void> _loadMemos() async {
    _memos = await _services.getNextExecutableMemosChunk(collectionId: collectionId);
  }
}

abstract class CollectionExecutionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadingCollectionExecutionState extends CollectionExecutionState {}

class LoadedCollectionExecutionState extends CollectionExecutionState {
  LoadedCollectionExecutionState(this._currentMemo, {required this.completionValue});

  final Memo _currentMemo;
  List<Map<String, dynamic>> get rawQuestion => _currentMemo.rawQuestion;
  List<Map<String, dynamic>> get rawAnswer => _currentMemo.rawAnswer;

  /// A value ranging from `0` to `1` representing how close the user is to finishing the current execution
  final double completionValue;
}

class FinishedCollectionExecutionState extends CollectionExecutionState {}
