import 'dart:math';

import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/collection_execution.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:memo/domain/models/memo_execution.dart';

/// Handles all domain-specific operations associated with "Memory Recall".
abstract class MemoryRecallServices {
  /// Given a [memo] and the current time of this call (now), estimates a memory recall for this memo.
  ///
  /// Returns a value ranging from `0` to `1`, though never reaching an absolute value of `0` or `1`.
  ///
  /// The memory recall is considered really low if it's close to `0` or recent/high if closer to `1`.
  ///
  /// This may return `null` if [Memo.isPristine] is `true`, meaning that it has no execution to execute the recall
  /// calculation.
  double? evaluateMemoryRecall(MemoExecutionRecallMetadata memo);
}

class MemoryRecallServicesImpl implements MemoryRecallServices {
  @override
  double? evaluateMemoryRecall(MemoExecutionRecallMetadata memo) {
    if (memo.isPristine) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final totalRepetitions = memo.totalExecutions;
    final millisSinceLastExecution = now.difference(memo.lastExecution!).inMilliseconds;

    return _evaluateMemoRecall(
      millisSinceLastExecution: millisSinceLastExecution,
      totalRepetitions: totalRepetitions,
      lastDifficulty: memo.lastMarkedDifficulty!,
    );
  }

  /// Estimates an arbitrary value for a memory belonging to (one or more) executions of an individual `Memo`.
  ///
  /// The formula is strongly based on the
  /// [supermemo's "Forgetting Cruve"](https://supermemo.guru/wiki/Forgetting_curve), which is one of the elements that
  /// supermemo's algorithm uses, although here, we are using it as a heavy influence in our primary - and only -
  /// formula.
  ///
  /// ### The Formula
  ///
  /// Latex representation: `R = e^{-t/S}`, where:
  /// - `R` is our memory recall.
  /// - [e] base of the natural logarithms.
  /// - `t` time since the last execution for this memo.
  /// - `S` stability - or strength - for this memo.
  ///
  /// #### `t` variable
  ///
  /// To evaluate time `t`, we use the total time spent since last execution ([millisSinceLastExecution]), and divide it
  /// by the total time in a day, giving us a factor that increases linearly as the time goes by (with a millisecond of
  /// granularity).
  ///
  /// #### `s` variable
  ///
  /// Represents the last answer through a raw value (higher the value, higher the difficulty), where it cannot be lower
  /// than `Dmin`.
  ///
  /// `s = max(Dmax - D, Dmin)`
  ///
  /// Where `D` is the value for the last difficulty (represented by [lastDifficulty]) and `Dmax` is the
  /// `MemoDifficulty` with the highest possible value - the hardest - and `Dmin` is the `MemoDifficulty` with the
  /// lowest possible value - the easiest.
  ///
  // TODO(matuella): Solve the below:
  /// Ideally, it would be something more the average of all the difficulties in the past, but we haven't found a
  /// decent way to represent this in this equation, because we must find a non-subjective way to make the last
  /// responses take a more relevant weight when comparing to the past ones.
  ///
  /// ##### `r` variable
  ///
  /// Each time a `Memo` is executed, we count this as a repetition factor - an integer. That's what `r` represents, the
  /// total amount of times it was repeated ([totalRepetitions]) - each new repetition should strengthen the recall
  /// probability.
  ///
  /// ##### `k` constant
  ///
  /// This is an extra multiplying factor to both `s` and `r`.
  ///
  // TODO(matuella): Solve the below:
  /// So, this constant doesn't have a mathematical fundamentation, but because we found that the curve was decaying too
  /// fast, this was an alternative to prolongate the forgetting curve to a value that we expected to be more concise.
  ///
  /// #### `R` value
  ///
  /// A floating value **ranging** from `0` to `1`, although never an exact `0` or `1` integer.
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
