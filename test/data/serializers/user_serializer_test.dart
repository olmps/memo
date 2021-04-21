import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/user_serializer.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/user.dart';

void main() {
  final serializer = UserSerializer();

  test('UserSerializer should decode with optional properties', () {
    final rawUser = {
      UserKeys.executionsAmounts: {MemoDifficulty.easy.raw: 1},
      UserKeys.timeSpentInMillis: 5000,
    };

    final decodedUser = serializer.from(rawUser);

    final allPropsUser = User(executionsAmounts: const {MemoDifficulty.easy: 1}, timeSpentInMillis: 5000);

    expect(decodedUser, allPropsUser);
    expect(rawUser, serializer.to(decodedUser));
  });
}
