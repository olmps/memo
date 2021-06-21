import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Handles all analytics operations, such as recording errors, custom events and more
abstract class AnalyticsMonitor {
  /// Records an error that is thrown by a scoped zone
  ///
  /// Zoned error are those that are not caught by Flutter framework but ar caught when throwing inside a scoped zone.
  /// A common case is when an exception is happen inside `onPressed` event of a button:
  ///
  /// ```
  /// ElevatedButton(
  ///   onPressed: () {
  ///     throw Error();
  ///   }
  /// ...
  /// )
  /// ```
  Future<void> recordZoneError(dynamic exception, StackTrace? stack);

  /// Record an uncaught error that is thrown by Flutter framework
  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails);
}

class AnalyticsMonitorImpl implements AnalyticsMonitor {
  factory AnalyticsMonitorImpl() => instance;

  AnalyticsMonitorImpl._() {
    _setupCrashlytics();
  }

  static final AnalyticsMonitorImpl instance = AnalyticsMonitorImpl._();

  Future<void> _setupCrashlytics() async {
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }
  }

  @override
  Future<void> recordZoneError(dynamic exception, StackTrace? stack) =>
      FirebaseCrashlytics.instance.recordError(exception, stack);

  @override
  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails) =>
      FirebaseCrashlytics.instance.recordFlutterError(flutterErrorDetails);
}
