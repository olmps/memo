import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/view-models/app_vm.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:memo/domain/services/progress_services.dart';
import 'package:meta/meta.dart';

final progressVM = StateNotifierProvider<ProgressVM, ProgressState>((ref) {
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
          (key, value) => MapEntry(key, progress.hasExecutions ? value / progress.totalExecutionsAmount : 0),
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

  /// Total time spent in all memos (in milliseconds).
  final int timeSpentInMillis;
  TimeProgress get timeProgress => TimeProgress.fromDuration(Duration(milliseconds: timeSpentInMillis));

  final Map<MemoDifficulty, double> executionsPercentage;
  final int totalExecutions;

  @override
  List<Object?> get props => [timeSpentInMillis, executionsPercentage, totalExecutions];
}

/// Custom time representation that excludes components with zero-values.
///
/// Compresses each individual component into the smallest possible value and excludes all components that have a value
/// of zero.
///
/// I.e.:
///
/// Example 1:
/// ```
/// final duration = Duration(seconds: 10, minutes: 10);
/// final timeProgress = TimeProgress.fromDuration(duration);
///
/// timeProgress.hours == null; // true
/// timeProgress.minutes == 10; // true
/// timeProgress.seconds == 10; // true
/// ```
///
/// Example 2:
/// ```
/// final duration = Duration(hours: 1, seconds: 180);
/// final timeProgress = TimeProgress.fromDuration(duration);
///
/// timeProgress.hours == 1; // true
/// timeProgress.minutes == 3; // true
/// timeProgress.seconds == null; // true
/// ```
///
/// Example 3:
/// ```
/// final duration = Duration(minutes: 61, microseconds: 200);
/// final timeProgress = TimeProgress.fromDuration(duration);
///
/// timeProgress.hours == 1; // true
/// timeProgress.minutes == 1; // true
/// timeProgress.seconds == null; // true
/// ```
class TimeProgress {
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

  TimeProgress._({required this.hours, required this.minutes, required this.seconds});

  final int? hours;
  final int? minutes;
  final int? seconds;

  /// `true` only when the [seconds] component is present.
  bool get hasOnlySeconds => hours == null && minutes == null;

  /// `true` if all time components are `null`.
  bool get isEmpty => hours == null && minutes == null && seconds == null;
}
