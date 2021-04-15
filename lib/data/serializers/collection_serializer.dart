import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/collection.dart';

class CollectionSerializer implements Serializer<Collection, Map<String, dynamic>> {
  @override
  Collection from(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final name = json['name'] as String;
    final description = json['description'] as String;
    final category = json['category'] as String;

    final rawTags = json['tags'] as List;
    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final tags = rawTags.cast<String>();

    final timeSpentInMillis = json['timeSpentInMillis'] as int;
    final easyMemosAmount = json['easyMemosAmount'] as int;
    final mediumMemosAmount = json['mediumMemosAmount'] as int;
    final hardMemosAmount = json['hardMemosAmount'] as int;

    return Collection(
      id: id,
      name: name,
      description: description,
      category: category,
      tags: tags,
      timeSpentInMillis: timeSpentInMillis,
      easyMemosAmount: easyMemosAmount,
      mediumMemosAmount: mediumMemosAmount,
      hardMemosAmount: hardMemosAmount,
    );
  }

  @override
  Map<String, dynamic> to(Collection collection) => <String, dynamic>{
        'id': collection.id,
        'name': collection.name,
        'description': collection.description,
        'category': collection.category,
        'tags': collection.tags,
        'timeSpentInMillis': collection.timeSpentInMillis,
        'easyMemosAmount': collection.easyMemosAmount,
        'mediumMemosAmount': collection.mediumMemosAmount,
        'hardMemosAmount': collection.hardMemosAmount,
      };
}
