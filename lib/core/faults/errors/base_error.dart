import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Core [Error] class - every class that represent an [Error] should extend from [BaseError].
///
/// The difference between throwing an [Error] and an [Exception] can be found in their respective declarations in
/// `dart:core`.
@immutable
abstract class BaseError extends Error with EquatableMixin {
  BaseError({required this.type, required this.message});

  final ErrorType type;
  final String message;

  @override
  List<Object> get props => [type];

  @override
  String toString() => '$type - $message';
}

enum ErrorType {
  // InconsistentStateError
  inconsistentState,
  coordinatorInconsistentState,
  serviceInconsistentState,
  repositoryInconsistentState,
  viewModelInconsistentState,
  layoutInconsistentState,
  gatewayInconsistentState,

  // SerializationError
  serialization,
}
