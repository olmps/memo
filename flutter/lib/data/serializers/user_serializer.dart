import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/user.dart';

class UserKeys {
  static const memosExecutionChunkGoal = 'memosExecutionChunkGoal';
  static const executionsAmounts = 'executionsAmounts';
  static const timeSpentInMillis = 'timeSpentInMillis';
}

class UserSerializer implements Serializer<User, Map<String, dynamic>> {
  @override
  User from(Map<String, dynamic> json) {
    final memosExecutionChunkGoal = json[UserKeys.memosExecutionChunkGoal] as int;

    final rawExecutionsAmounts = json[UserKeys.executionsAmounts] as Map<String, dynamic>?;
    final executionsAmounts =
        rawExecutionsAmounts?.map((key, dynamic value) => MapEntry(memoDifficultyFromRaw(key), value as int));

    final timeSpentInMillis = json[UserKeys.timeSpentInMillis] as int?;

    return User(
      memosExecutionChunkGoal: memosExecutionChunkGoal,
      executionsAmounts: executionsAmounts ?? {},
      timeSpentInMillis: timeSpentInMillis ?? 0,
    );
  }

  @override
  Map<String, dynamic> to(User memo) => <String, dynamic>{
        UserKeys.memosExecutionChunkGoal: memo.memosExecutionChunkGoal,
        UserKeys.executionsAmounts: memo.executionsAmounts.map((key, value) => MapEntry(key.raw, value)),
        UserKeys.timeSpentInMillis: memo.timeSpentInMillis,
      };
}
