import 'dart:math';

import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo.dart';

/// Handles all domain-specific operations pertaining to the concept of Memory Stability
abstract class MemoryStabilityServices {
  /// Given a [memo] and the current time of this call, estimates a memory stability for this memo
  ///
  /// The returned `double` ranges from `0` to `1`, but because it's an exponential operation, it should never reach
  /// those integers values, just approximate them if the memory stability is really low (meaning close to `0`) or if
  /// it's really recent/high (close to `1`).
  ///
  /// This may return `null` if [Memo.isPristine] is `true`, meaning that it has no execution to execute the stability
  /// calculation.
  double? evaluateMemoryStability(Memo memo);
}

class MemoryStabilityServicesImpl implements MemoryStabilityServices {
  @override
  double? evaluateMemoryStability(Memo memo) {
    final now = DateTime.now().toUtc();

    if (memo.isPristine) {
      return null;
    }

    final totalRepetitions = memo.totalExecutionsAmount;
    final millisSinceLastExecution = now.difference(memo.lastExecuted!).inMilliseconds;

    return _evaluateMemoStability(
      millisSinceLastExecution: millisSinceLastExecution,
      totalRepetitions: totalRepetitions,
      lastDifficulty: memo.lastMarkedDifficulty!,
    );
  }

  double _evaluateMemoStability({
    required int millisSinceLastExecution,
    required int totalRepetitions,
    required MemoDifficulty lastDifficulty,
  }) {
    assert(millisSinceLastExecution > 0 && totalRepetitions > 0, '');

    // Constant `k`
    const k = 5;

    // Variable `t` (time)
    final t = millisSinceLastExecution / Duration.millisecondsPerDay;

    // Variable `s` (stability)
    final s = max(k - lastDifficulty.stabilityFactor, 1);

    final decayFactor = -t / (s * totalRepetitions * k);

    return pow(e, decayFactor) as double;
  }
}

extension on MemoDifficulty {
  int get stabilityFactor {
    switch (this) {
      case MemoDifficulty.easy:
        return 1;
      case MemoDifficulty.medium:
        return 2;
      case MemoDifficulty.hard:
        return 3;
    }
  }
}
