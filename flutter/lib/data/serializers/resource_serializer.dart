import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/enums/resource_type.dart';
import 'package:memo/domain/models/resource.dart';

class ResourceKeys {
  static const id = 'id';
  static const description = 'description';
  static const type = 'type';
  static const url = 'url';
  static const tags = 'tags';
}

class ResourceSerializer implements Serializer<Resource, Map<String, dynamic>> {
  @override
  Resource from(Map<String, dynamic> json) {
    final id = json[ResourceKeys.id] as String;
    final description = json[ResourceKeys.description] as String;
    final rawType = json[ResourceKeys.type] as String;
    final type = _typeFromRaw(rawType);

    final url = json[ResourceKeys.url] as String;

    final rawTags = json[ResourceKeys.tags] as List;
    final tags = List<String>.from(rawTags);

    return Resource(
      id: id,
      description: description,
      tags: tags,
      type: type,
      url: url,
    );
  }

  @override
  Map<String, dynamic> to(Resource resource) => <String, dynamic>{
        ResourceKeys.id: resource.id,
        ResourceKeys.description: resource.description,
        ResourceKeys.tags: resource.tags,
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
