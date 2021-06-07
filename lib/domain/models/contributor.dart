import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// One of the [Contributor]'s in the [Collection]
@immutable
class Contributor extends Equatable {
  const Contributor({
    required this.id,
    required this.githubUser,
    required this.url,
    required this.imageUrl,
  });

  final String id;

  /// This [Contributor] github user with the [@]
  final String githubUser;

  /// This [Contributor] image url
  final String imageUrl;

  /// URL that links to this particular [Contributor]
  final String url;

  @override
  List<Object?> get props => [id, githubUser, imageUrl, url];
}
