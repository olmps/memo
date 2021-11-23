import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_providers.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';
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
  void updateMetadata({required CollectionMetadata metadata});

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
        collectionMetadata: CollectionMetadata.empty(),
        memosMetadata: const [],
        hasValidDetails: false,
      );
    } on BaseException catch (exception) {
      state = UpdateCollectionFailedLoading(exception);
    }
  }

  @override
  void updateMetadata({required CollectionMetadata metadata}) =>
      state = loadedState.copyWith(metadata: metadata, hasValidDetails: _validateDetails(metadata: metadata));

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
  bool _validateDetails({required CollectionMetadata metadata}) {
    try {
      validateCollectionName(metadata.name);
      validateCollectionDescription(metadata.description.plainText);

      return true;
    } on BaseException catch (_) {
      return false;
    }
  }
}

@immutable
class CollectionMetadata extends Equatable {
  const CollectionMetadata({required this.name, required this.description, required this.tags});

  factory CollectionMetadata.empty() => const CollectionMetadata(
        name: '',
        description: RichTextEditingValue(),
        tags: [],
      );

  final String name;
  final RichTextEditingValue description;
  final List<String> tags;

  CollectionMetadata copyWith({String? name, RichTextEditingValue? description, List<String>? tags}) =>
      CollectionMetadata(
        name: name ?? this.name,
        description: description ?? this.description,
        tags: tags ?? this.tags,
      );

  @override
  List<Object?> get props => [name, tags, description];
}

@immutable
class MemoMetadata extends Equatable {
  const MemoMetadata({required this.question, required this.answer});

  factory MemoMetadata.empty() => const MemoMetadata(question: '', answer: '');

  final String question;
  final String answer;

  @override
  List<Object?> get props => [question, answer];
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

  final CollectionMetadata collectionMetadata;
  final List<MemoMetadata> memosMetadata;

  /// `true` if [collectionMetadata] has valid inputs.
  final bool hasValidDetails;

  /// Returns `true` if the collection has at least one memo.
  bool get hasMemos => memosMetadata.isNotEmpty;

  /// Returns `true` if the collection is ready to be saved.
  bool get canSaveCollection => hasValidDetails && hasMemos;

  UpdateCollectionLoaded copyWith({CollectionMetadata? metadata, List<MemoMetadata>? memos, bool? hasValidDetails}) =>
      UpdateCollectionLoaded(
        collectionMetadata: metadata ?? collectionMetadata,
        memosMetadata: memos ?? memosMetadata,
        hasValidDetails: hasValidDetails ?? this.hasValidDetails,
      );

  UpdateCollectionSaving copyForSaving() => UpdateCollectionSaving(
      metadata: collectionMetadata, memosMetadata: memosMetadata, hasValidDetails: hasValidDetails);

  UpdateCollectionSaved copyForSaved() => UpdateCollectionSaved(
      metadata: collectionMetadata, memosMetadata: memosMetadata, hasValidDetails: hasValidDetails);

  @override
  List<Object?> get props => [...super.props, collectionMetadata, memosMetadata, hasValidDetails];
}

class UpdateCollectionSaving extends UpdateCollectionLoaded {
  const UpdateCollectionSaving({
    required CollectionMetadata metadata,
    required List<MemoMetadata> memosMetadata,
    required bool hasValidDetails,
  }) : super(collectionMetadata: metadata, memosMetadata: memosMetadata, hasValidDetails: hasValidDetails);
}

class UpdateCollectionSaved extends UpdateCollectionLoaded {
  const UpdateCollectionSaved({
    required CollectionMetadata metadata,
    required List<MemoMetadata> memosMetadata,
    required bool hasValidDetails,
  }) : super(collectionMetadata: metadata, memosMetadata: memosMetadata, hasValidDetails: hasValidDetails);
}

class UpdateCollectionFailedSaving extends UpdateCollectionLoaded {
  const UpdateCollectionFailedSaving(
    this.exception, {
    required CollectionMetadata metadata,
    required List<MemoMetadata> memosMetadata,
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
