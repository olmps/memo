import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_metadata.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_providers.dart';
import 'package:memo/core/faults/exceptions/base_exception.dart';
import 'package:memo/domain/validators/collection_validators.dart';

final updateCollectionVM = StateNotifierProvider.autoDispose<UpdateCollectionVM, UpdateCollectionState>(
  (ref) => UpdateCollectionVMImpl(collectionId: ref.watch(updateCollectionId)),
  dependencies: [updateCollectionId],
  name: 'updateCollectionVM',
);

abstract class UpdateCollectionVM extends StateNotifier<UpdateCollectionState> {
  UpdateCollectionVM({required this.collectionId, required UpdateCollectionState state}) : super(state);

  final String? collectionId;

  /// Returns `true` if editing an existing collection.
  bool get isEditing;

  /// Loads [collectionId] metadata if not `null` or create an empty metadata if creating a new collection.
  ///
  /// Emits [UpdateCollectionFailedLoading] if it fails to load [collectionId].
  Future<void> loadContent();

  /// Updates collection details metadata.
  ///
  /// To persist the collection updates, use [saveCollection].
  void updateMetadata({required CollectionUpdateMetadata metadata});

  /// Updates collection memos metadata.
  ///
  /// To persist the collection use [saveCollection].
  void updateMemos({required List<MemoUpdateMetadata> memos});

  /// Reorders memos list moving memo from [oldIndex] to [newIndex].
  void swapMemoIndex(int oldIndex, int newIndex);

  /// Save the created/edited collection.
  ///
  /// Emits [UpdateCollectionFailedSaving] if it fails to save the collection.
  Future<void> saveCollection();
}

class UpdateCollectionVMImpl extends UpdateCollectionVM {
  UpdateCollectionVMImpl({
    String? collectionId,
  }) : super(collectionId: collectionId, state: UpdateCollectionLoading()) {
    loadContent();
  }

  @override
  bool get isEditing => collectionId != null;

  UpdateCollectionLoaded get loadedState => state as UpdateCollectionLoaded;

  @override
  Future<void> loadContent() async {
    state = UpdateCollectionLoading();

    try {
      // TODO(ggirotto): Call services to load [collectionId] if necessary or create an empty collection metadata
      await Future<void>.delayed(const Duration(seconds: 2));

      state = UpdateCollectionLoaded(
        collectionMetadata: CollectionUpdateMetadata.empty(),
        memosMetadata: const [],
        hasValidDetails: false,
      );
    } on BaseException catch (exception) {
      state = UpdateCollectionFailedLoading(exception);
    }
  }

  @override
  void updateMetadata({required CollectionUpdateMetadata metadata}) =>
      state = loadedState.copyWith(metadata: metadata, hasValidDetails: _validateDetails(metadata: metadata));

  @override
  void updateMemos({required List<MemoUpdateMetadata> memos}) => state = loadedState.copyWith(memos: memos);

  @override
  void swapMemoIndex(int oldIndex, int newIndex) {
    final removedMetadata = loadedState.memosMetadata.removeAt(oldIndex);
    final updatedMemos = loadedState.memosMetadata..insert(newIndex, removedMetadata);
    state = loadedState.copyWith(memos: updatedMemos);
  }

  @override
  Future<void> saveCollection() async {
    final loadedState = state as UpdateCollectionLoaded;
    try {
      // TODO(ggirotto): Call services to save the collection

    } on BaseException catch (exception) {
      state = UpdateCollectionFailedSaving(
        exception,
        metadata: loadedState.collectionMetadata,
        memosMetadata: loadedState.memosMetadata,
        hasValidDetails: _validateDetails(metadata: loadedState.collectionMetadata),
      );
    }
  }

  /// Returns `true` if [metadata] fields are valid.
  bool _validateDetails({required CollectionUpdateMetadata metadata}) {
    try {
      validateCollectionName(metadata.name);
      validateCollectionDescription(metadata.description.plainContent);

      return true;
    } on BaseException catch (_) {
      return false;
    }
  }
}

@immutable
abstract class UpdateCollectionState extends Equatable {
  const UpdateCollectionState();

  @override
  List<Object?> get props => [];
}

class UpdateCollectionLoading extends UpdateCollectionState {}

class UpdateCollectionLoaded extends UpdateCollectionState {
  const UpdateCollectionLoaded({
    required this.collectionMetadata,
    required this.memosMetadata,
    required this.hasValidDetails,
  });

  final CollectionUpdateMetadata collectionMetadata;
  final List<MemoUpdateMetadata> memosMetadata;

  /// `true` if [collectionMetadata] has valid inputs.
  final bool hasValidDetails;

  /// Returns `true` if the collection has at least one memo.
  bool get hasMemos => memosMetadata.isNotEmpty;

  /// Returns `true` if the collection is ready to be saved.
  bool get canSaveCollection => hasValidDetails && hasMemos;

  UpdateCollectionLoaded copyWith({
    CollectionUpdateMetadata? metadata,
    List<MemoUpdateMetadata>? memos,
    bool? hasValidDetails,
  }) =>
      UpdateCollectionLoaded(
        collectionMetadata: metadata ?? collectionMetadata,
        memosMetadata: memos ?? memosMetadata,
        hasValidDetails: hasValidDetails ?? this.hasValidDetails,
      );

  UpdateCollectionSaving copyForSaving() => UpdateCollectionSaving(
        metadata: collectionMetadata,
        memosMetadata: memosMetadata,
        hasValidDetails: hasValidDetails,
      );

  UpdateCollectionSaved copyForSaved() => UpdateCollectionSaved(
        metadata: collectionMetadata,
        memosMetadata: memosMetadata,
        hasValidDetails: hasValidDetails,
      );

  @override
  List<Object?> get props => [...super.props, collectionMetadata, memosMetadata, hasValidDetails];
}

class UpdateCollectionSaving extends UpdateCollectionLoaded {
  const UpdateCollectionSaving({
    required CollectionUpdateMetadata metadata,
    required List<MemoUpdateMetadata> memosMetadata,
    required bool hasValidDetails,
  }) : super(collectionMetadata: metadata, memosMetadata: memosMetadata, hasValidDetails: hasValidDetails);
}

class UpdateCollectionSaved extends UpdateCollectionLoaded {
  const UpdateCollectionSaved({
    required CollectionUpdateMetadata metadata,
    required List<MemoUpdateMetadata> memosMetadata,
    required bool hasValidDetails,
  }) : super(collectionMetadata: metadata, memosMetadata: memosMetadata, hasValidDetails: hasValidDetails);
}

class UpdateCollectionFailedSaving extends UpdateCollectionLoaded {
  const UpdateCollectionFailedSaving(
    this.exception, {
    required CollectionUpdateMetadata metadata,
    required List<MemoUpdateMetadata> memosMetadata,
    required bool hasValidDetails,
  }) : super(collectionMetadata: metadata, memosMetadata: memosMetadata, hasValidDetails: hasValidDetails);

  final BaseException exception;

  @override
  List<Object?> get props => [...super.props, exception];
}

class UpdateCollectionFailedLoading extends UpdateCollectionState {
  const UpdateCollectionFailedLoading(this.exception);

  final BaseException exception;

  @override
  List<Object?> get props => [...super.props, exception];
}
