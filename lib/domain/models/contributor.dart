import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

// ignore: comment_references
/// One of the [Contributor]'s in the [Collection]
@immutable
class Contributor extends Equatable {
  const Contributor({
    required this.name,
    required this.url,
    required this.imageUrl,
  });

  final String name;

  final String imageUrl;

  /// An external url - chosen by the collection contributor - which is linked within the `SingleContributorButton`
  final String url;

  @override
  List<Object?> get props => [name, imageUrl, url];
}
