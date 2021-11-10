import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/core/faults/exceptions/base_exception.dart';
import 'package:memo/core/faults/exceptions/url_exception.dart';

final updateCollectionVM = StateNotifierProvider.family<UpdateCollectionVM, String?>(
    (ref, collectionId) => UpdateCollectionVMImpl(collectionId: collectionId));

abstract class UpdateCollectionVM extends StateNotifier<UpdateCollectionState> {
  UpdateCollectionVM({required this.collectionId, required UpdateCollectionState state}) : super(state);

  final String? collectionId;

  /// Returns `true` if editing an existing collection.
  bool get isEditing;

  /// Loads [collectionId] metadata if not `null` or create an empty metadata if creating a new collection.
  ///
  /// Emits [UpdateCollectionFailedLoading] if it fails to load [collectionId].
  Future<void> loadInitialContent();

  /// Save the created/edited collection.
  ///
  /// Emits [UpdateCollectionFailedSaving] if it fails to save the collection.
  Future<void> saveCollection();
}

class UpdateCollectionVMImpl extends UpdateCollectionVM {
  UpdateCollectionVMImpl({String? collectionId}) : super(collectionId: collectionId, state: UpdateCollectionLoading()) {
    loadInitialContent();
  }

  @override
  bool get isEditing => collectionId != null;

  @override
  Future<void> loadInitialContent() async {
    state = UpdateCollectionLoading();

    try {
      // TODO: Call services to load [collectionId] if necessary or create an empty collection metadata
      await Future<void>.delayed(const Duration(seconds: 2));

      // state = UpdateCollectionLoaded(collectionMetadata: CollectionMetadata.empty());
      state = UpdateCollectionFailedSaving(
        UrlException.failedToOpen(),
        metadata: CollectionMetadata.empty(),
        memosMetadata: const [],
      );
    } on BaseException catch (exception) {
      state = UpdateCollectionFailedLoading(exception);
    }
  }

  @override
  Future<void> saveCollection() async {
    final loadedState = state as UpdateCollectionLoaded;
    try {
      // TODO: Call services to save the collection
      print('Saving collection...');
    } on BaseException catch (exception) {
      state = UpdateCollectionFailedSaving(
        exception,
        metadata: loadedState.collectionMetadata,
        memosMetadata: loadedState.memosMetadata,
      );
    }
  }
}

@immutable
class CollectionMetadata extends Equatable {
  const CollectionMetadata({required this.name, required this.tags, required this.description});

  factory CollectionMetadata.empty() => const CollectionMetadata(name: '', description: '', tags: []);

  final String name;
  final List<String> tags;
  final String description;

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
  const UpdateCollectionLoaded({required this.collectionMetadata, required this.memosMetadata});

  final CollectionMetadata collectionMetadata;
  final List<MemoMetadata> memosMetadata;

  /// Returns `true` if all required information from `Details` segment has been added.
  bool get hasDetails =>
      collectionMetadata.name.isNotEmpty &&
      collectionMetadata.description.isNotEmpty &&
      collectionMetadata.tags.isNotEmpty;

  /// Returns `true` if the collection has at least one memo.
  bool get hasMemos => memosMetadata.isNotEmpty;

  @override
  List<Object?> get props => [...super.props, collectionMetadata];
}

class UpdateCollectionFailedSaving extends UpdateCollectionLoaded {
  const UpdateCollectionFailedSaving(
    this.exception, {
    required CollectionMetadata metadata,
    required List<MemoMetadata> memosMetadata,
  }) : super(collectionMetadata: metadata, memosMetadata: memosMetadata);

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
