import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/enums/resource_type.dart';
import 'package:memo/domain/models/collection.dart';

class CollectionKeys {
  static const id = 'id';
  static const name = 'name';
  static const category = 'category';
  static const description = 'description';
  static const locale = 'locale';
  static const tags = 'tags';

  static const memosAmount = 'memosAmount';
  static const memosOrder = 'memosOrder';

  static const contributors = 'contributors';
  static const resources = 'resources';
}

class CollectionSerializer implements Serializer<Collection, Map<String, dynamic>> {
  final contributorSerializer = ContributorSerializer();
  final resourceSerializer = ResourceSerializer();

  @override
  Collection from(Map<String, dynamic> json) {
    final id = json[CollectionKeys.id] as String;
    final name = json[CollectionKeys.name] as String;

    final memosAmount = json[CollectionKeys.memosAmount] as int;

    final rawMemosOrder = json[CollectionKeys.memosOrder] as List;
    final memosOrder = List<String>.from(rawMemosOrder);

    final category = json[CollectionKeys.category] as String?;
    final description = json[CollectionKeys.description] as String?;
    final locale = json[CollectionKeys.description] as String?;

    final rawTags = json[CollectionKeys.tags] as List?;
    final tags = rawTags != null ? List<String>.from(rawTags) : null;

    final rawContributors = List<Map<String, dynamic>>.from(json[CollectionKeys.contributors] as List);
    final contributors = rawContributors.map(contributorSerializer.from).toList();

    final rawResources = List<Map<String, dynamic>>.from(json[CollectionKeys.resources] as List);
    final resources = rawResources.map(resourceSerializer.from).toList();

    return Collection(
      id: id,
      name: name,
      description: description,
      category: category,
      locale: locale,
      tags: tags,
      memosAmount: memosAmount,
      memosOrder: memosOrder,
      contributors: contributors,
      resources: resources,
    );
  }

  @override
  Map<String, dynamic> to(Collection collection) => <String, dynamic>{
        CollectionKeys.id: collection.id,
        CollectionKeys.name: collection.name,
        CollectionKeys.memosAmount: collection.memosAmount,
        CollectionKeys.memosOrder: collection.memosOrder,
        if (collection.description != null) CollectionKeys.description: collection.description,
        if (collection.category != null) CollectionKeys.category: collection.category,
        if (collection.locale != null) CollectionKeys.locale: collection.locale,
        if (collection.tags != null) CollectionKeys.tags: collection.tags,
        if (collection.contributors != null)
          CollectionKeys.contributors: collection.contributors!.map(contributorSerializer.to),
        if (collection.resources != null) CollectionKeys.resources: collection.resources!.map(resourceSerializer.to),
      };
}

class ResourceKeys {
  static const id = 'id';
  static const description = 'description';
  static const type = 'type';
  static const url = 'url';
}

class ResourceSerializer implements Serializer<Resource, Map<String, dynamic>> {
  @override
  Resource from(Map<String, dynamic> json) {
    final id = json[ResourceKeys.id] as String;
    final description = json[ResourceKeys.description] as String;
    final rawType = json[ResourceKeys.type] as String;
    final type = _typeFromRaw(rawType);

    final url = json[ResourceKeys.url] as String;

    return Resource(
      id: id,
      description: description,
      type: type,
      url: url,
    );
  }

  @override
  Map<String, dynamic> to(Resource resource) => <String, dynamic>{
        ResourceKeys.id: resource.id,
        ResourceKeys.description: resource.description,
        ResourceKeys.type: resource.type.raw,
        ResourceKeys.url: resource.url,
      };

  ResourceType _typeFromRaw(String raw) => ResourceType.values.firstWhere(
        (type) => type.raw == raw,
        orElse: () => ResourceType.unknown,
      );
}

extension on ResourceType {
  String get raw {
    switch (this) {
      case ResourceType.article:
        return 'article';
      case ResourceType.book:
        return 'book';
      case ResourceType.video:
        return 'video';
      case ResourceType.unknown:
        return 'unknown';
    }
  }
}

class ContributorKeys {
  static const name = 'name';
  static const url = 'url';
  static const imageUrl = 'imageUrl';
}

class ContributorSerializer implements Serializer<Contributor, Map<String, dynamic>> {
  @override
  Contributor from(Map<String, dynamic> json) {
    final name = json[ContributorKeys.name] as String;
    final url = json[ContributorKeys.url] as String?;
    final imageUrl = json[ContributorKeys.imageUrl] as String?;

    return Contributor(name: name, url: url, imageUrl: imageUrl);
  }

  @override
  Map<String, dynamic> to(Contributor contributor) => <String, dynamic>{
        ContributorKeys.name: contributor.name,
        if (contributor.url != null) ContributorKeys.url: contributor.url,
        if (contributor.imageUrl != null) ContributorKeys.imageUrl: contributor.imageUrl,
      };
}

class CategoryKeys {
  static const id = 'id';
  static const name = 'name';
}

class CategorySerializer implements Serializer<Category, Map<String, dynamic>> {
  @override
  Category from(Map<String, dynamic> json) {
    final id = json[CategoryKeys.id] as String;
    final name = json[CategoryKeys.name] as String;

    return Category(id: id, name: name);
  }

  @override
  Map<String, dynamic> to(Category category) => <String, dynamic>{
        CategoryKeys.id: category.id,
        CategoryKeys.name: category.name,
      };
}
