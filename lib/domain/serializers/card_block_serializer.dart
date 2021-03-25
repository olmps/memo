import 'package:memo/core/faults/errors/serialization_error.dart';
import 'package:memo/data/database_repository.dart';
import 'package:memo/domain/enums/card_block_type.dart';
import 'package:memo/domain/models/card.dart';

class CardBlockSerializer implements JsonSerializer<CardBlock> {
  @override
  CardBlock fromMap(Map<String, dynamic> json) {
    final rawType = json['type'] as String;
    final type = _typeFromRaw(rawType);

    final rawContents = json['rawContents'] as String;

    return CardBlock(type: type, rawContents: rawContents);
  }

  @override
  Map<String, dynamic> mapOf(CardBlock block) => <String, dynamic>{
        'type': block.type.raw,
        'rawContents': block.rawContents,
      };

  CardBlockType _typeFromRaw(String raw) => CardBlockType.values.firstWhere(
        (type) => type.raw == raw,
        orElse: () {
          throw SerializationError("Failed to find a CardBlockType with the raw vale of '$raw'");
        },
      );
}

extension on CardBlockType {
  String get raw {
    switch (this) {
      case CardBlockType.text:
        return 'text';
      case CardBlockType.htmlText:
        return 'htmlText';
      case CardBlockType.image:
        return 'image';
      case CardBlockType.code:
        return 'code';
    }
  }
}
