import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/contributor.dart';

class ContributorKeys {
  static const id = 'uniqueId';
  static const githubUser = 'githubUser';
  static const url = 'url';
  static const imageUrl = 'imageUrl';
}

class ContributorSerializer implements Serializer<Contributor, dynamic> {
  @override
  // ignore: avoid_annotating_with_dynamic
  Contributor from(dynamic json) {
    final id = json[ContributorKeys.id] as String;
    final githubUser = json[ContributorKeys.githubUser] as String;
    final url = json[ContributorKeys.url] as String;
    final imageUrl = json[ContributorKeys.imageUrl] as String;

    return Contributor(
      id: id,
      githubUser: githubUser,
      url: url,
      imageUrl: imageUrl,
    );
  }

  @override
  Map<String, dynamic> to(Contributor contributor) => <String, dynamic>{
        ContributorKeys.id: contributor.id,
        ContributorKeys.githubUser: contributor.githubUser,
        ContributorKeys.url: contributor.url,
        ContributorKeys.imageUrl: contributor.imageUrl,
      };
}
