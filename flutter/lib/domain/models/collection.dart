import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/resource_type.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:meta/meta.dart';

/// Metadata for a collection (group) of its associated `Memo`s.
///
/// Through [MemoExecutionsMetadata], this class also includes properties that describes its executed `Memo`s.
@immutable
class Collection with EquatableMixin {
  Collection({
    required this.id,
    required this.name,
    required this.memosAmount,
    required this.memosOrder,
    this.category,
    this.description,
    this.locale,
    this.tags,
    this.contributors,
    this.resources,
  });

  final String id;
  final String name;

  final int memosAmount;
  final List<String> memosOrder;

  final String? locale;
  final String? description;
  final String? category;

  final List<String>? tags;
  final List<Contributor>? contributors;
  final List<Resource>? resources;

  @override
  List<Object?> get props => [
        id,
        name,
        memosAmount,
        memosOrder,
        locale,
        description,
        category,
        tags,
        contributors,
        resources,
      ];
}

/// Metadata for a collection.
// abstract class CollectionMetadata {
//   String get id;
//   String get name;
//   String get description;
//   String get category;

//   /// Abstract tags that are used to group and identify this collection.
//   List<String> get tags;

//   /// Contributors (or owners) that have created (or made changes) to this collection.
//   List<Contributor> get contributors;

//   /// Total amount of unique `Memo`s associated with this collection.
//   int get uniqueMemosAmount;

//   /// Total amount of unique `Memo`s associated with this collection that have been executed at least once.
//   int get uniqueMemoExecutionsAmount;
// }

/// A collection contributor.
@immutable
class Contributor extends Equatable {
  const Contributor({required this.name, this.url, this.imageUrl});

  /// Name identifer for this contributor.
  final String name;

  /// Avatar image url for this contributor.
  final String? imageUrl;

  /// A self-promotion url for this contributor, like a github profile, portfolio website, etcetera.
  final String? url;

  @override
  List<Object?> get props => [name, imageUrl, url];
}

/// Enhances the usage of a single [url] with associated properties, like [description] and [type].
@immutable
class Resource extends Equatable {
  const Resource({required this.id, required this.description, required this.type, required this.url});

  final String id;

  /// Human-readable description for this description.
  final String description;

  /// Describes which type of [url] this resource refers to.
  final ResourceType type;

  /// URL that links to this particular [Resource].
  final String url;

  @override
  List<Object?> get props => [id, description, type, url];
}

@immutable
class Category extends Equatable {
  const Category({required this.id, required this.name});

  /// Name identifer for this contributor.
  final String id;

  /// Name for this category.
  final String name;

  @override
  List<Object?> get props => [id, name];
}
