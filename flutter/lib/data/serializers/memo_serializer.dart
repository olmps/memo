import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/memo.dart';

class MemoKeys {
  static const id = 'id';
  static const question = 'question';
  static const answer = 'answer';
}

class MemoSerializer implements Serializer<Memo, Map<String, dynamic>> {
  @override
  Memo from(Map<String, dynamic> json) {
    final id = json[MemoKeys.id] as String;
    final question = List<Map<String, dynamic>>.from(json[MemoKeys.question] as List);
    final answer = List<Map<String, dynamic>>.from(json[MemoKeys.answer] as List);

    return Memo(id: id, question: question, answer: answer);
  }

  @override
  Map<String, dynamic> to(Memo execution) => <String, dynamic>{
        MemoKeys.id: execution.id,
        MemoKeys.question: execution.question,
        MemoKeys.answer: execution.answer,
      };
}
