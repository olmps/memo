import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/resource_type.dart';
import 'package:meta/meta.dart';

/// Enhances the usage of a single [url] with associated properties, like [tags] and [type]
@immutable
class Resource extends Equatable {
  Resource({required this.id, required this.description, required this.tags, required this.type, required this.url})
      : assert(tags.isNotEmpty, 'tags must have at least one element');

  final String id;

  /// Human-readable description for this description.
  final String description;

  /// Abstract tags that are used to group and identify this resource.
  final List<String> tags;

  /// Describes which type of [url] this resource refers to.
  final ResourceType type;

  /// URL that links to this particular [Resource].
  final String url;

  @override
  List<Object?> get props => [id, description, tags, type, url];
}
