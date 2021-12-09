import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_metadata.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_providers.dart';

final updateCollectionMemosVM = StateNotifierProvider.autoDispose<UpdateCollectionMemosVM, UpdateMemosState>(
  (ref) => UpdateCollectionMemosVMImpl(memos: ref.read(updateMemosMetadata)),
  dependencies: [updateMemosMetadata],
  name: 'updateCollectionMemosVM',
);

abstract class UpdateCollectionMemosVM extends StateNotifier<UpdateMemosState> {
  UpdateCollectionMemosVM(UpdateMemosState state) : super(state);

  /// Replaces the current saved memos with [memos].
  void updateMemos(List<MemoUpdateMetadata> memos);

  /// Creates a new empty Memo in the collection.
  void createEmptyMemo();

  /// Updates memo at [index] metadata with [metadata].
  void updateMemoAtIndex(int index, {required MemoUpdateMetadata metadata});

  /// Removes the memo at given [index].
  ///
  /// If [index] is not in range `0 <= index < memos.length` does nothing.
  void removeMemoAtIndex(int index);
}

class UpdateCollectionMemosVMImpl extends UpdateCollectionMemosVM {
  UpdateCollectionMemosVMImpl({required List<MemoUpdateMetadata> memos}) : super(UpdateMemosState(memos: memos));

  @override
  void updateMemos(List<MemoUpdateMetadata> memos) => state = state.copyWith(memos: memos);

  @override
  void createEmptyMemo() {
    // Creates an empty memo metadata using an incremental identifier.
    final emptyMemo = MemoUpdateMetadata.empty(id: state.memos.length + 1);
    final updatedMemos = List<MemoUpdateMetadata>.from(state.memos)..add(emptyMemo);
    state = state.copyWith(memos: updatedMemos);
  }

  @override
  void updateMemoAtIndex(int index, {required MemoUpdateMetadata metadata}) {
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

    final updatedMemos = List<MemoUpdateMetadata>.from(state.memos)..removeAt(index);
    state = state.copyWith(memos: updatedMemos);
  }
}

class UpdateMemosState extends Equatable {
  const UpdateMemosState({required this.memos});

  final List<MemoUpdateMetadata> memos;

  UpdateMemosState copyWith({required List<MemoUpdateMetadata> memos}) => UpdateMemosState(memos: memos);

  @override
  List<Object?> get props => [memos];
}
