import 'package:memo/core/faults/errors/serialization_error.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/enums/memo_block_type.dart';
import 'package:memo/domain/models/memo_block.dart';

class MemoBlockSerializer implements Serializer<MemoBlock, Map<String, dynamic>> {
  @override
  MemoBlock from(Map<String, dynamic> json) {
    final rawType = json['type'] as String;
    final type = _typeFromRaw(rawType);

    final rawContents = json['rawContents'] as String;

    return MemoBlock(type: type, rawContents: rawContents);
  }

  @override
  Map<String, dynamic> to(MemoBlock block) => <String, dynamic>{
        'type': block.type.raw,
        'rawContents': block.rawContents,
      };

  MemoBlockType _typeFromRaw(String raw) => MemoBlockType.values.firstWhere(
        (type) => type.raw == raw,
        orElse: () {
          throw SerializationError("Failed to find a MemoBlockType with the raw value of '$raw'");
        },
      );
}

extension on MemoBlockType {
  String get raw {
    switch (this) {
      case MemoBlockType.text:
        return 'text';
      case MemoBlockType.htmlText:
        return 'htmlText';
      case MemoBlockType.image:
        return 'image';
      case MemoBlockType.code:
        return 'code';
    }
  }
}
