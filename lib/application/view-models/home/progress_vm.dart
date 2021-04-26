import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/view-models/app_vm.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:memo/domain/services/progress_services.dart';
import 'package:meta/meta.dart';

final progressVM = StateNotifierProvider<ProgressVM>((ref) {
  return ProgressVMImpl(ref.read(progressServices));
});

abstract class ProgressVM extends StateNotifier<ProgressState> {
  ProgressVM(ProgressState state) : super(state);
}

class ProgressVMImpl extends ProgressVM {
  ProgressVMImpl(this._services) : super(LoadingProgressState()) {
    _addProgressListener();
  }

  final ProgressServices _services;
  StreamSubscription<MemoExecutionsMetadata>? _progressListener;

  Future<void> _addProgressListener() async {
    final progressStream = await _services.listenToUserProgress();
    _progressListener = progressStream.listen((progress) {
      state = LoadedProgressState(
        timeSpentInMillis: progress.timeSpentInMillis,
        executionsPercentage: progress.executionsAmounts.map(
          (key, value) => MapEntry(key, value / progress.totalExecutionsAmount),
        ),
        totalExecutions: progress.totalExecutionsAmount,
      );
    });
  }

  @override
  void dispose() {
    _progressListener?.cancel();
    super.dispose();
  }
}

@immutable
abstract class ProgressState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadingProgressState extends ProgressState {}

class LoadedProgressState extends ProgressState {
  LoadedProgressState({
    required this.timeSpentInMillis,
    required this.executionsPercentage,
    required this.totalExecutions,
  });

  /// Total time spent in all memos (in milliseconds)
  final int timeSpentInMillis;
  TimeProgress get timeProgress => TimeProgress.fromDuration(Duration(milliseconds: timeSpentInMillis));

  final Map<MemoDifficulty, double> executionsPercentage;
  final int totalExecutions;

  @override
  List<Object?> get props => [timeSpentInMillis, executionsPercentage, totalExecutions];
}

/// Helper that excludes time components with zero-values
///
/// This not only exclude values that are have a value of `0`, but also implicitly compress to the smallest possible
/// representable value. So, if we have a `Duration` with `60` minutes, this would be compressed in a single hour.
///
/// I.e.:
///
/// Scenario 1:
/// ```
/// final duration = Duration(seconds: 10, minutes: 10);
/// final timeProgress = TimeProgress.fromDuration(duration);
///
/// timeProgress.hours == null; // true
/// timeProgress.minutes == 10; // true
/// timeProgress.seconds == 10; // true
/// ```
///
/// Scenario 2:
/// ```
/// final duration = Duration(hours: 1, seconds: 180);
/// final timeProgress = TimeProgress.fromDuration(duration);
///
/// timeProgress.hours == 1; // true
/// timeProgress.minutes == 3; // true
/// timeProgress.seconds == null; // true
/// ```
///
/// Scenario 3:
/// ```
/// final duration = Duration(minutes: 61, microseconds: 200);
/// final timeProgress = TimeProgress.fromDuration(duration);
///
/// timeProgress.hours == 1; // true
/// timeProgress.minutes == 1; // true
/// timeProgress.seconds == null; // true
/// ```
class TimeProgress {
  // Private constructor, we don't want direct instantiation of this class
  TimeProgress._({required this.hours, required this.minutes, required this.seconds});

  factory TimeProgress.fromDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return TimeProgress._(
      hours: hours == 0 ? null : seconds,
      minutes: minutes == 0 ? null : minutes,
      seconds: seconds == 0 ? null : seconds,
    );
  }

  final int? hours;
  final int? minutes;
  final int? seconds;

  /// `true` if all time components are `null`
  bool get isEmpty => hours == null && minutes == null && seconds == null;
}
