import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memo/application/widgets/theme/rich_text_field.dart';

/// Holds `Collection` properties when updating a `Collection`.
@immutable
class CollectionUpdateMetadata extends Equatable {
  const CollectionUpdateMetadata({required this.name, required this.description, required this.tags});

  factory CollectionUpdateMetadata.empty() =>
      const CollectionUpdateMetadata(name: '', description: MemoUpdateContent(), tags: []);

  final String name;
  final MemoUpdateContent description;
  final List<String> tags;

  CollectionUpdateMetadata copyWith({String? name, MemoUpdateContent? description, List<String>? tags}) =>
      CollectionUpdateMetadata(
        name: name ?? this.name,
        description: description ?? this.description,
        tags: tags ?? this.tags,
      );

  @override
  List<Object?> get props => [name, tags, description];
}

/// Holds `Memo` properties when updating a `Collection`.
@immutable
class MemoUpdateMetadata extends Equatable {
  const MemoUpdateMetadata({required this.id, required this.question, required this.answer});

  factory MemoUpdateMetadata.empty({required int id}) =>
      MemoUpdateMetadata(id: id, question: const MemoUpdateContent(), answer: const MemoUpdateContent());

  MemoUpdateMetadata copyWith({int? id, MemoUpdateContent? question, MemoUpdateContent? answer}) =>
      MemoUpdateMetadata(id: id ?? this.id, question: question ?? this.question, answer: answer ?? this.answer);

  final int id;
  final MemoUpdateContent question;
  final MemoUpdateContent answer;

  @override
  List<Object?> get props => [id, question, answer];
}

/// Holds `Memo` question/answer properties when updating a `Collection`.
@immutable
class MemoUpdateContent extends Equatable {
  const MemoUpdateContent({this.richContent = '', this.plainContent = ''});

  /// Rich content from a `Memo` question/answer.
  final String richContent;

  /// Plain content from a `Memo` question/answer.
  final String plainContent;

  @override
  List<Object?> get props => [richContent, plainContent];
}

/// Maps a [MemoUpdateContent] to a [RichTextEditingValue].
RichTextEditingValue mapMemoUpdateContentToRichTextValue(MemoUpdateContent content) =>
    RichTextEditingValue(plainText: content.plainContent, richText: content.richContent);

/// Maps a [RichTextEditingValue] to a [MemoUpdateContent].
MemoUpdateContent mapRichTextValueToMemoUpdateContent(RichTextEditingValue value) =>
    MemoUpdateContent(plainContent: value.plainText, richContent: value.richText);
