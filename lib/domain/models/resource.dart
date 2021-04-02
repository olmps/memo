import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/resource_type.dart';
import 'package:meta/meta.dart';

@immutable
class Resource extends Equatable {
  Resource({required this.id, required this.description, required this.tags, required this.type, required this.url})
      : assert(tags.isNotEmpty, 'tags must have at least one element');

  final String id;

  final String description;

  /// List of tags that can associate with this [Resource]
  ///
  /// This is useful in cases where we must match a `Deck.tags` with each available resources
  final List<String> tags;

  /// Metadata that describes which type of [url] this resource refers to
  ///
  /// Example types: "video", "article", etctera.
  final ResourceType type;

  /// URL that links to this particular [Resource]
  final String url;

  @override
  List<Object?> get props => [id, description, tags, url];
}
