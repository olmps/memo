import 'package:memo/core/faults/errors/serialization_error.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';

MemoDifficulty memoDifficultyFromRaw(String raw) => MemoDifficulty.values.firstWhere(
      (type) => type.raw == raw,
      orElse: () {
        throw SerializationError("Failed to find a MemoDifficulty with the raw value of '$raw'");
      },
    );

extension RawMemoDifficulty on MemoDifficulty {
  String get raw {
    switch (this) {
      case MemoDifficulty.easy:
        return 'easy';
      case MemoDifficulty.medium:
        return 'medium';
      case MemoDifficulty.hard:
        return 'hard';
    }
  }
}
