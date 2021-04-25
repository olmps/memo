import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/user.dart';

class UserKeys {
  static const dailyMemosGoal = 'dailyMemosGoal';
  static const executionsAmounts = 'executionsAmounts';
  static const timeSpentInMillis = 'timeSpentInMillis';
}

class UserSerializer implements Serializer<User, Map<String, dynamic>> {
  @override
  User from(Map<String, dynamic> json) {
    final dailyMemosGoal = json[UserKeys.dailyMemosGoal] as int;

    final rawExecutionsAmounts = json[UserKeys.executionsAmounts] as Map<String, dynamic>?;
    final executionsAmounts =
        // ignore: avoid_annotating_with_dynamic
        rawExecutionsAmounts?.map((key, dynamic value) => MapEntry(memoDifficultyFromRaw(key), value as int));

    final timeSpentInMillis = json[UserKeys.timeSpentInMillis] as int?;

    return User(
      dailyMemosGoal: dailyMemosGoal,
      executionsAmounts: executionsAmounts ?? {},
      timeSpentInMillis: timeSpentInMillis ?? 0,
    );
  }

  @override
  Map<String, dynamic> to(User memo) => <String, dynamic>{
        UserKeys.dailyMemosGoal: memo.dailyMemosGoal,
        UserKeys.executionsAmounts: memo.executionsAmounts.map((key, value) => MapEntry(key.raw, value)),
        UserKeys.timeSpentInMillis: memo.timeSpentInMillis,
      };
}
