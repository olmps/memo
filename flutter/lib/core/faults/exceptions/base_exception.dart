import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

typedef ExceptionObserver = void Function(BaseException exception);

/// The core [Exception] class - every class that represents an [Exception] should extend from [BaseException].
///
/// The difference between throwing an [Error] and an [Exception] can be found in their respective declarations in
/// `dart.core`.
@immutable
abstract class BaseException extends Equatable implements Exception {
  BaseException({required this.type, this.debugInfo, this.debugData, this.message}) {
    observer?.call(this);
  }

  final ExceptionType type;

  final String? debugInfo;
  final dynamic debugData;

  /// Optional message used as the exception message in the Scaffold when the exception is thrown.
  final String? message;

  /// Unique instance to observe all [BaseException] instances.
  ///
  /// This observer is called whenever the constructor body - of a new [BaseException] instance - runs.
  static ExceptionObserver? observer;

  @override
  List<Object> get props => [type];

  @override
  String toString() => '''
  [BaseException - $type] $debugInfo.
  Debug Data: $debugData
  ''';
}

enum ExceptionType {
  // UrlException
  failedToOpenUrl,

  // Validation
  emptyField,
  fieldLengthExceeded,
}
