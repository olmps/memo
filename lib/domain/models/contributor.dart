import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// One of the [Contributor]'s in the `Collection`
@immutable
class Contributor extends Equatable {
  const Contributor({required this.name, required this.url, required this.imageUrl});

  final String name;

  final String imageUrl;

  /// An external url which references a website from the user choice to be used in self-promotion contexts
  final String url;

  @override
  List<Object?> get props => [name, imageUrl, url];
}
