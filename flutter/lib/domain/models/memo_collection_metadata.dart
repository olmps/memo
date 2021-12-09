import 'package:equatable/equatable.dart';

/// Metadata for a memo that belongs to a collection.
class MemoCollectionMetadata with EquatableMixin {
  MemoCollectionMetadata({required this.uniqueId, required this.rawQuestion, required this.rawAnswer})
      : assert(rawQuestion.isNotEmpty),
        assert(rawQuestion.first.isNotEmpty),
        assert(rawAnswer.isNotEmpty),
        assert(rawAnswer.first.isNotEmpty);

  /// A global unique id.
  ///
  /// This id must be unique both in the parent's `Collection` and through all other `Memo`.
  final String uniqueId;

  /// Raw representation of a `Memo` question.
  ///
  /// A question may be composed of an arbitrary amount of styled elements. Each of these elements - an untyped `Map` -
  /// are a raw representation of this styled element, allowing each to have a completely different structure from the
  /// other.
  final List<Map<String, dynamic>> rawQuestion;

  /// Raw representation of a `Memo` answer
  ///
  /// An answer may be composed of an arbitrary amount of styled elements. Each of these elements - an untyped `Map` -
  /// are a raw representation of this styled element, allowing each to have a completely different structure from the
  /// other.
  final List<Map<String, dynamic>> rawAnswer;

  @override
  List<Object?> get props => [uniqueId, rawQuestion, rawAnswer];
}
