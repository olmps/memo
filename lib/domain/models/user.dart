import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:meta/meta.dart';

/// Holds preferences and the user's application metadata (by extending [MemoExecutionsMetadata])
@immutable
class User extends MemoExecutionsMetadata {
  User({
    Map<MemoDifficulty, int> executionsAmounts = const {},
    int timeSpentInMillis = 0,
  }) : super(timeSpentInMillis, executionsAmounts);
}
