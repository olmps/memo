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
  double? evaluateMemoryRecall(Memo memo);
}

class MemoryStabilityServicesImpl implements MemoryStabilityServices {
  @override
  double? evaluateMemoryRecall(Memo memo) {
    if (memo.isPristine) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final totalRepetitions = memo.totalExecutionsAmount;
    final millisSinceLastExecution = now.difference(memo.lastExecuted!).inMilliseconds;

    return _evaluateMemoRecall(
      millisSinceLastExecution: millisSinceLastExecution,
      totalRepetitions: totalRepetitions,
      lastDifficulty: memo.lastMarkedDifficulty!,
    );
  }

  /// Estimates an arbitrary value for a particular memory pertaining to (one or more) executions of a single `Memo`
  ///
  /// The formula is strongly based on the
  /// [supermemo's "Forgetting Cruve"](https://supermemo.guru/wiki/Forgetting_curve), which is one of the elements that
  /// supermemo's algorithm uses, although we are using it as a heavy influence in our primary - and only - formula, to
  /// estimate how often one should see one `Memo`.
  ///
  /// ### The Formula
  ///
  /// Latex representation: `R = e^{-t/S}`, where:
  /// - `R` is our memory stability;
  /// - [e] base of the natural logarithms;
  /// - `t` time since the last execution for this memo;
  /// - `S` stability - or strenght - for this memo.
  ///
  /// #### `t` variable
  ///
  /// To evaluate time, `t`, we use the total time spent since the last execution (represented by
  /// [millisSinceLastExecution]), and divide it by the total time in a day, giving us a factor that increases linearly
  /// as the time goes by (with a millisecond of granularity).
  ///
  /// #### `s` variable
  ///
  /// Represents the last answer through a raw value (higher the value, higher the difficulty), where it cannot
  /// be lower than `Dmin`.
  ///
  /// `s = max(Dmax - D, Dmin)`
  ///
  /// Where `D` is the value for the last difficulty (represented by [lastDifficulty]) and `Dmax` is the
  /// `MemoDifficulty` with the highest possible value - meaning, the hardest - and `Dmin` is the
  /// `MemoDifficulty` with the lowest possible value - meaning, the easiest.
  ///
  /// Ideally, it would be something more the average of all the difficulties in the past, but we haven't found a
  /// decent way to represent this in this equation, because we must find a non-subjective way to make the last
  /// responses take a more relevant weight when comparing to the past ones.
  ///
  /// ##### `r` variable
  ///
  /// Each time a `Memo` is executed, we count this as a repetition factor - a simple integer. That's what `r`
  /// represents, the total amount of times it was repeated (represented by [totalRepetitions]) - each new repetition
  /// should strengthen the recall probability.
  ///
  /// ##### `k` constant
  ///
  /// This is an extra multiplying factor to both `s` and `r`.
  ///
  /// So, this constant doesn't have a mathematical fundamentation, but because we found that the curve was decaying too
  /// fast, this was an alternative to prolongate the forgetting curve to a value that we expected to be more concise.
  ///
  /// #### `R` value
  ///
  /// Returns a floating value ranging from `0` to `1`.
  ///
  /// The higher, the better is the probability of recalling a `Memo` that meets these conditions.
  ///
  /// ### Where this formula stands today
  ///
  /// It's pretty clear that this formula doesn't take into consideration a couple of relevant info, with the aim of
  /// being more precise, but this also makes things more difficult and may be a little bit out of the scope with the
  /// knowledge that we have, related to the fundamentals of memories and SRS.
  ///
  /// This formula should - and probably will - be changed multiple times in the future and, while this earlier formula
  /// version does what it's proposed to, it lacks concerns that we are aware of, but don't know exactly how to solve.
  double _evaluateMemoRecall({
    required int millisSinceLastExecution,
    required int totalRepetitions,
    required MemoDifficulty lastDifficulty,
  }) {
    assert(
      millisSinceLastExecution > 0 && totalRepetitions > 0,
      'Expected `millisSinceLastExecution` and `totalRepetitions` to be positive integers',
    );
    // Variable `t` (time)
    final t = millisSinceLastExecution / Duration.millisecondsPerDay;

    // Variable `r`
    final r = totalRepetitions;

    // Variable `s`
    final s = max(3 - lastDifficulty.stabilityFactor, 1);

    // Constant `k`
    const k = 5;

    // Variable `S` (stability)
    final decayFactor = -t / (s * r * k);

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
