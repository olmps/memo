import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/card_block_type.dart';
import 'package:meta/meta.dart';

/// Wraps the [rawContents] of a "segment" of the respective `Card` answer/question
///
/// This is just a single piece of a `Card`'s question or answer, which can be composed of multiple [CardBlock]s.
@immutable
class CardBlock extends Equatable {
  CardBlock({required this.type, required this.rawContents}) : assert(rawContents.isNotEmpty);

  final CardBlockType type;
  final String rawContents;

  @override
  List<Object?> get props => [type, rawContents];
}
