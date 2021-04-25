import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/user_serializer.dart';
import 'package:memo/domain/models/user.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = UserSerializer();

  test('UserSerializer should decode with optional properties', () {
    final rawUser = fixtures.user();

    final decodedUser = serializer.from(rawUser);
    final allPropsUser = User(dailyMemosGoal: 10);

    expect(decodedUser, allPropsUser);
    expect(rawUser, serializer.to(decodedUser));
  });
}
