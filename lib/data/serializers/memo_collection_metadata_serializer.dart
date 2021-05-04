import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';

class MemoCollectionMetadataKeys {
  static const uniqueId = 'uniqueId';
  static const rawQuestion = 'question';
  static const rawAnswer = 'answer';
}

class MemoCollectionMetadataSerializer implements Serializer<MemoCollectionMetadata, Map<String, dynamic>> {
  @override
  MemoCollectionMetadata from(Map<String, dynamic> json) {
    final uniqueId = json[MemoCollectionMetadataKeys.uniqueId] as String;

    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final rawQuestion = List<Map<String, dynamic>>.from(json[MemoCollectionMetadataKeys.rawQuestion] as List);
    final rawAnswer = List<Map<String, dynamic>>.from(json[MemoCollectionMetadataKeys.rawAnswer] as List);

    return MemoCollectionMetadata(uniqueId: uniqueId, rawQuestion: rawQuestion, rawAnswer: rawAnswer);
  }

  @override
  Map<String, dynamic> to(MemoCollectionMetadata metadata) => <String, dynamic>{
        MemoCollectionMetadataKeys.uniqueId: metadata.uniqueId,
        MemoCollectionMetadataKeys.rawQuestion: metadata.rawQuestion,
        MemoCollectionMetadataKeys.rawAnswer: metadata.rawAnswer,
      };
}
