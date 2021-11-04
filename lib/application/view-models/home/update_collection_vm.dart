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
      state = UpdateCollectionFailedSaving(UrlException.failedToOpen(), metadata: CollectionMetadata.empty());
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
      state = UpdateCollectionFailedSaving(exception, metadata: loadedState.collectionMetadata);
    }
  }
}

@immutable
class CollectionMetadata {
  const CollectionMetadata({
    required this.name,
    required this.tags,
    required this.description,
    required this.memoMetadata,
  });

  factory CollectionMetadata.empty() => const CollectionMetadata(name: '', description: '', tags: [], memoMetadata: []);

  final String name;
  final List<String> tags;
  final String description;
  final List<MemoMetadata> memoMetadata;
}

@immutable
class MemoMetadata {
  const MemoMetadata({required this.question, required this.answer});

  factory MemoMetadata.empty() => const MemoMetadata(question: '', answer: '');

  final String question;
  final String answer;
}

@immutable
abstract class UpdateCollectionState extends Equatable {
  const UpdateCollectionState();

  @override
  List<Object?> get props => [];
}

class UpdateCollectionLoading extends UpdateCollectionState {}

class UpdateCollectionLoaded extends UpdateCollectionState {
  const UpdateCollectionLoaded({required this.collectionMetadata});

  final CollectionMetadata collectionMetadata;

  bool get hasDetails => true;
  bool get hasMemos => false;

  @override
  List<Object?> get props => [...super.props, collectionMetadata];
}

class UpdateCollectionFailedSaving extends UpdateCollectionLoaded {
  const UpdateCollectionFailedSaving(this.exception, {required CollectionMetadata metadata})
      : super(collectionMetadata: metadata);

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
