import 'package:memo/data/database_repository.dart';
import 'package:memo/domain/models/resource.dart';

class ResourceSerializer implements JsonSerializer<Resource> {
  @override
  Resource fromMap(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final description = json['description'] as String;
    final url = json['url'] as String;

    final rawTags = json['tags'] as List;
    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final tags = rawTags.cast<String>();

    return Resource(
      id: id,
      description: description,
      tags: tags,
      url: url,
    );
  }

  @override
  Map<String, dynamic> mapOf(Resource resource) => <String, dynamic>{
        'id': resource.id,
        'description': resource.description,
        'url': resource.url,
        'tags': resource.tags,
      };
}
