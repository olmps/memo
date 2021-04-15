import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_block_type.dart';
import 'package:meta/meta.dart';

/// Wraps the [rawContents] of a "segment" of the respective `Memo` answer/question
///
/// This is just a single piece of a `Memo`'s question or answer, which can be composed of multiple [MemoBlock]s.
@immutable
class MemoBlock extends Equatable {
  MemoBlock({required this.type, required this.rawContents}) : assert(rawContents.isNotEmpty);

  final MemoBlockType type;
  final String rawContents;

  @override
  List<Object?> get props => [type, rawContents];
}
