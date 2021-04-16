import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

final progressVM = StateNotifierProvider<ProgressVM>((_) => ProgressVMImpl());

abstract class ProgressVM extends StateNotifier<ProgressState> {
  ProgressVM(ProgressState state) : super(state);
}

class ProgressVMImpl extends ProgressVM {
  ProgressVMImpl() : super(LoadingProgressState()) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    // TODO(matuella): attach logic
    await Future.delayed(const Duration(seconds: 1), () {});

    state = LoadedProgressState(
      timeSpentInMillis: 20000000,
      hardMemosCount: 17,
      mediumMemosCount: 37,
      easyMemosCount: 97,
    );
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
    required this.hardMemosCount,
    required this.mediumMemosCount,
    required this.easyMemosCount,
  });

  /// Total time spent in all memos (in milliseconds)
  final int timeSpentInMillis;
  TimeProgress get timeProgress => TimeProgress.fromDuration(Duration(milliseconds: timeSpentInMillis));

  int get completedMemosCount => hardMemosCount + mediumMemosCount + easyMemosCount;

  String get readableHardMemosPercentage => (hardMemosPercentage * 100).round().toString();
  double get hardMemosPercentage => hardMemosCount / completedMemosCount;
  final int hardMemosCount;

  String get readableMediumMemosPercentage => (mediumMemosPercentage * 100).round().toString();
  double get mediumMemosPercentage => mediumMemosCount / completedMemosCount;
  final int mediumMemosCount;

  String get readableEasyMemosPercentage => (easyMemosPercentage * 100).round().toString();
  double get easyMemosPercentage => easyMemosCount / completedMemosCount;
  final int easyMemosCount;

  @override
  List<Object?> get props => [timeSpentInMillis, hardMemosCount, mediumMemosCount, easyMemosCount];
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
