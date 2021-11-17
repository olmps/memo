import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memo/application/pages/home/collections/update/update_collection_providers.dart';
import 'package:memo/application/view-models/home/update_collection_vm.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';
import 'package:memo/core/faults/exceptions/base_exception.dart';
import 'package:memo/domain/validators/collection_validators.dart';

final updateCollectionDetailsVM = StateNotifierProvider.autoDispose<UpdateCollectionDetailsVM, UpdatedDetailsState>(
  (ref) => UpdateCollectionDetailsVMImpl(metadata: ref.read(updateDetailsMetadata)),
  dependencies: [updateDetailsMetadata],
  name: 'updateCollectionDetailsVM',
);

abstract class UpdateCollectionDetailsVM extends StateNotifier<UpdatedDetailsState> {
  UpdateCollectionDetailsVM({required UpdatedDetailsState state}) : super(state);

  /// Updates the collection name.
  ///
  /// Emits [UpdateDetailsInvalid] if [name] isn't a valid name.
  void updateName(String name);

  void updateTags(List<String> tags);

  /// Updates the collection description.
  ///
  /// Emits [UpdateDetailsInvalid] if [description] isn't a valid description.
  void updateDescription(RichTextEditingValue description);
}

class UpdateCollectionDetailsVMImpl extends UpdateCollectionDetailsVM {
  UpdateCollectionDetailsVMImpl({
    required CollectionMetadata metadata,
  }) : super(state: UpdatedDetailsState(metadata: metadata));

  @override
  void updateName(String name) {
    try {
      validateCollectionName(name);
      state = state.copyWith(name: name);
    } on BaseException catch (exception) {
      state = state.copyForInvalidName(exception);
    }
  }

  @override
  void updateTags(List<String> tags) => state = state.copyWith(tags: tags);

  @override
  void updateDescription(RichTextEditingValue description) {
    try {
      validateCollectionDescription(description.plainText);
      state = state.copyWith(description: description);
    } on BaseException catch (exception) {
      state = state.copyForInvalidDescription(exception);
    }
  }
}

class UpdatedDetailsState extends Equatable {
  const UpdatedDetailsState({required this.metadata});

  final CollectionMetadata metadata;

  UpdatedDetailsState copyWith({String? name, List<String>? tags, RichTextEditingValue? description}) =>
      UpdatedDetailsState(metadata: metadata.copyWith(name: name, tags: tags, description: description));

  UpdateDetailsInvalid copyForInvalidName(BaseException exception) =>
      UpdateDetailsInvalid(nameException: exception, metadata: metadata);

  UpdateDetailsInvalid copyForInvalidDescription(BaseException exception) =>
      UpdateDetailsInvalid(descriptionException: exception, metadata: metadata);

  @override
  List<Object?> get props => [metadata];
}

class UpdateDetailsInvalid extends UpdatedDetailsState {
  const UpdateDetailsInvalid({required CollectionMetadata metadata, this.nameException, this.descriptionException})
      : super(metadata: metadata);

  final BaseException? nameException;
  final BaseException? descriptionException;

  @override
  List<Object?> get props => super.props..addAll([nameException, descriptionException]);
}
