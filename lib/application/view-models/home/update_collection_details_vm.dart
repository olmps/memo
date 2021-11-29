import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_metadata.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_providers.dart';
import 'package:memo/core/faults/exceptions/base_exception.dart';
import 'package:memo/domain/validators/collection_validators.dart' as validators;
import 'package:rxdart/rxdart.dart';

final updateCollectionDetailsVM = StateNotifierProvider.autoDispose<UpdateCollectionDetailsVM, UpdatedDetailsState>(
  (ref) => UpdateCollectionDetailsVMImpl(metadata: ref.read(updateDetailsMetadata)),
  dependencies: [updateDetailsMetadata],
  name: 'updateCollectionDetailsVM',
);

abstract class UpdateCollectionDetailsVM extends StateNotifier<UpdatedDetailsState> {
  UpdateCollectionDetailsVM({required UpdatedDetailsState state}) : super(state);

  /// Streams the field state on each update.
  ///
  /// If a validation exception happens when validating the [name] input field, the stream emits a
  /// `ValidationException`.
  Stream<String> get name;

  /// Receives a update event on the collection name field.
  ///
  /// Every update event will trigger a update on [name] stream which may emit a validation exception.
  void updateName(String updatedName);

  /// Streams the field state on each update.
  ///
  /// If a validation exception happens when validating the [tags] input field, the stream emits a
  /// `ValidationException`.
  Stream<List<String>> get tags;

  /// Receives a update event on the collection tags field.
  ///
  /// Every update event will trigger a update on [tags] stream which may emit a validation exception.
  void updateTags(List<String> tags);

  /// Streams the field state on each update.
  ///
  /// If a validation exception happens when validating the [description] input field, the stream emits a
  /// `ValidationException`.
  Stream<MemoUpdateContent> get description;

  /// Receives a update event on the collection description field.
  ///
  /// Every update event will trigger a update on [description] stream which may emit a validation exception.
  void updateDescription(MemoUpdateContent updatedDescription);
}

class UpdateCollectionDetailsVMImpl extends UpdateCollectionDetailsVM {
  UpdateCollectionDetailsVMImpl({required CollectionUpdateMetadata metadata})
      : _collectionNameController = BehaviorSubject.seeded(metadata.name),
        _collectionTagsController = BehaviorSubject.seeded(metadata.tags),
        _collectionDescriptionController = BehaviorSubject.seeded(metadata.description),
        super(state: UpdatedDetailsState(metadata: metadata));

  final BehaviorSubject<String> _collectionNameController;
  final BehaviorSubject<List<String>> _collectionTagsController;
  final BehaviorSubject<MemoUpdateContent> _collectionDescriptionController;

  @override
  Stream<String> get name =>
      _collectionNameController.stream.transform(StreamTransformer.fromHandlers(handleData: _nameValidator));

  @override
  void updateName(String updatedName) {
    _collectionNameController.sink.add(updatedName);
    state = state.copyWith(name: updatedName);
  }

  @override
  Stream<List<String>> get tags => _collectionTagsController.stream;

  @override
  void updateTags(List<String> tags) {
    _collectionTagsController.sink.add(tags);
    state = state.copyWith(tags: tags);
  }

  @override
  Stream<MemoUpdateContent> get description => _collectionDescriptionController.stream
      .transform(StreamTransformer.fromHandlers(handleData: _descriptionValidator));

  @override
  void updateDescription(MemoUpdateContent updatedDescription) {
    _collectionDescriptionController.sink.add(updatedDescription);
    state = state.copyWith(description: updatedDescription);
  }

  void _nameValidator(String name, EventSink<String> sink) {
    try {
      validators.validateCollectionName(name);
      sink.add(name);
    } on BaseException catch (exception) {
      sink.addError(exception);
    }
  }

  void _descriptionValidator(MemoUpdateContent description, EventSink<MemoUpdateContent> sink) {
    try {
      validators.validateCollectionDescription(description.plainContent);
      sink.add(description);
    } on BaseException catch (exception) {
      sink.addError(exception);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _collectionNameController.close();
    _collectionTagsController.close();
    _collectionDescriptionController.close();
  }
}

class UpdatedDetailsState extends Equatable {
  const UpdatedDetailsState({required this.metadata});

  final CollectionUpdateMetadata metadata;

  UpdatedDetailsState copyWith({String? name, List<String>? tags, MemoUpdateContent? description}) =>
      UpdatedDetailsState(metadata: metadata.copyWith(name: name, tags: tags, description: description));

  @override
  List<Object?> get props => [metadata];
}
