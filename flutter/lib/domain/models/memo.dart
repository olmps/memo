import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Metadata for an unit of a collection - a `Memo`.
///
/// Stores the latest answer/question for this `Memo`, which can change over time.
///
/// Through [MemoExecutionsMetadata], this class also includes properties that describes its associated executions.
///
/// See also:
///   - `Collection`, which groups all metadata for the execution of its multiple associated `Memo`.
///   - `MemoExecution`, which represents an individual execution of a `Memo`.
@immutable
// ignore: avoid_implementing_value_types
class Memo with EquatableMixin {
  Memo({required this.id, required this.question, required this.answer})
      : assert(question.isNotEmpty),
        assert(question.first.isNotEmpty),
        assert(answer.isNotEmpty),
        assert(answer.first.isNotEmpty);

  final String id;

  /// Raw representation of a `Memo` question.
  ///
  /// A question may be composed of an arbitrary amount of styled elements. Each of these elements - an untyped `Map` -
  /// are a raw representation of this styled element, allowing each to have a completely different structure from the
  /// other.
  final List<Map<String, dynamic>> question;

  /// Raw representation of a `Memo` answer
  ///
  /// An answer may be composed of an arbitrary amount of styled elements. Each of these elements - an untyped `Map` -
  /// are a raw representation of this styled element, allowing each to have a completely different structure from the
  /// other.
  final List<Map<String, dynamic>> answer;

  @override
  List<Object?> get props => [id, question, answer];
}
