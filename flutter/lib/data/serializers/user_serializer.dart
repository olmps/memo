import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/user.dart';

class UserKeys {
  static const id = 'id';
  static const executionChunk = 'executionsChunk';
  static const executionsDifficulty = 'executionsDifficulty';
  static const timeSpentInMillis = 'timeSpentInMillis';
}

class UserSerializer implements Serializer<User, Map<String, dynamic>> {
  @override
  User from(Map<String, dynamic> json) {
    final id = json[UserKeys.id] as String;
    final executionChunk = json[UserKeys.executionChunk] as int;

    final rawExecutionsDifficulty = json[UserKeys.executionsDifficulty] as Map<String, dynamic>?;
    final executionsDifficulty =
        rawExecutionsDifficulty?.map((key, dynamic value) => MapEntry(memoDifficultyFromRaw(key), value as int));

    final timeSpentInMillis = json[UserKeys.timeSpentInMillis] as int?;

    return User(
      id: id,
      executionChunk: executionChunk,
      executionsDifficulty: executionsDifficulty ?? {},
      timeSpentInMillis: timeSpentInMillis ?? 0,
    );
  }

  @override
  Map<String, dynamic> to(User user) => <String, dynamic>{
        UserKeys.id: user.id,
        UserKeys.executionChunk: user.executionChunk,
        UserKeys.executionsDifficulty: user.executionsDifficulty.map((key, value) => MapEntry(key.raw, value)),
        UserKeys.timeSpentInMillis: user.timeSpentInMillis,
      };
}
