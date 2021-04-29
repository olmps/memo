/// Fundamental fields that defines a `Memo` when relating to a `Collection`
class MemoCollectionMetadata {
  MemoCollectionMetadata({required this.uniqueId, required this.rawQuestion, required this.rawAnswer})
      : assert(rawQuestion.isNotEmpty),
        assert(rawQuestion.first.isNotEmpty),
        assert(rawAnswer.isNotEmpty),
        assert(rawAnswer.first.isNotEmpty);

  /// Identifies a global unique id (unique both in the parent's `Collection` and through all other `Memo`)
  final String uniqueId;

  /// Raw representation of a `Memo` question
  ///
  /// Because a question may be composed of an arbitrary amount of styled elements, each raw "block", "piece", or even
  /// an "element", will have a completely different structure from each other. In this scenario, a [List] of [Map]
  /// (which is usually a JSON) is a reasonable fit for this  customized structure.
  final List<Map<String, dynamic>> rawQuestion;

  /// Raw representation of a `Memo` answer
  ///
  /// Because an answer may be composed of an arbitrary amount of styled elements, each raw "block", "piece", or even
  /// an "element", will have a completely different structure from each other. In this scenario, a [List] of [Map]
  /// (which is usually a JSON) is a reasonable fit for this  customized structure.
  final List<Map<String, dynamic>> rawAnswer;
}
