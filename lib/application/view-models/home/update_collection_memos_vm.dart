import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_providers.dart';
import 'package:memo/application/view-models/home/update_collection_vm.dart';

final updateCollectionMemosVM = StateNotifierProvider.autoDispose<UpdateCollectionMemosVM, UpdateMemosState>(
  (ref) => UpdateCollectionMemosVMImpl(memos: ref.read(updateMemosMetadata)),
  dependencies: [updateMemosMetadata],
  name: 'updateCollectionMemosVM',
);

abstract class UpdateCollectionMemosVM extends StateNotifier<UpdateMemosState> {
  UpdateCollectionMemosVM(UpdateMemosState state) : super(state);

  /// Replaces the current saved memos with [memos].
  void updateMemos(List<MemoMetadata> memos);

  /// Creates a new empty Memo in the collection.
  void createEmptyMemo();

  /// Updates memo at [index] metadata with [metadata].
  void updateMemoAtIndex(int index, {required MemoMetadata metadata});

  /// Removes the memo at given [index].
  ///
  /// If [index] is not in range `0 <= index < memos.length` does nothing.
  void removeMemoAtIndex(int index);
}

class UpdateCollectionMemosVMImpl extends UpdateCollectionMemosVM {
  UpdateCollectionMemosVMImpl({required List<MemoMetadata> memos}) : super(UpdateMemosState(memos: memos));

  @override
  void updateMemos(List<MemoMetadata> memos) => state = state.copyWith(memos: memos);

  @override
  void createEmptyMemo() {
    final updatedMemos = List<MemoMetadata>.from(state.memos)..add(MemoMetadata.empty());
    state = state.copyWith(memos: updatedMemos);
  }

  @override
  void updateMemoAtIndex(int index, {required MemoMetadata metadata}) {
    final updatedMemos = state.memos
      ..removeAt(index)
      ..insert(index, metadata);

    state = state.copyWith(memos: updatedMemos);
  }

  @override
  void removeMemoAtIndex(int index) {
    if (index < 0 || index >= state.memos.length) {
      return;
    }

    final updatedMemos = List<MemoMetadata>.from(state.memos)..removeAt(index);
    state = state.copyWith(memos: updatedMemos);
  }
}

class UpdateMemosState extends Equatable {
  const UpdateMemosState({required this.memos});

  final List<MemoMetadata> memos;

  UpdateMemosState copyWith({required List<MemoMetadata> memos}) => UpdateMemosState(memos: memos);

  @override
  List<Object?> get props => [memos];
}
