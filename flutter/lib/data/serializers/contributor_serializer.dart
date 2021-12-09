import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/collection.dart';

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
