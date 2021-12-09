import 'package:memo/core/faults/errors/base_error.dart';

/// Inconsistent state through the developer's logic.
///
/// Thrown in unexpected scenarios where an arbitrary logic should never fail.
///
/// An [InconsistentStateError] should never be thrown where any external dependencies fail, like opening a third-party
/// plugin and/or library, making network calls, and so on.
class InconsistentStateError extends BaseError {
  /// Creates a new generic inconsistency error that can't be attributed to a major application layer.
  ///
  /// See also:
  ///   - [InconsistentStateError.coordinator] - for inconsistent states in the coordinator.
  ///   - [InconsistentStateError.service] - for inconsistent states in services.
  ///   - [InconsistentStateError.repository] - for inconsistent states in repositories.
  ///   - [InconsistentStateError.viewModel] - for inconsistent states in VMs.
  ///   - [InconsistentStateError.layout] - for inconsistent states in the layout.
  ///   - [InconsistentStateError.gateway] - for inconsistent states in gateways.
  InconsistentStateError(String message) : super(type: ErrorType.inconsistentState, message: message);

  /// Creates a new error to represent the coordinator's inconsistent state.
  InconsistentStateError.coordinator(String message)
      : super(type: ErrorType.coordinatorInconsistentState, message: message);

  /// Creates a new error to represent a service inconsistent state.
  InconsistentStateError.service(String message) : super(type: ErrorType.serviceInconsistentState, message: message);

  /// Creates a new error to represent a repository inconsistent state.
  InconsistentStateError.repository(String message)
      : super(type: ErrorType.repositoryInconsistentState, message: message);

  /// Creates a new error to represent a viewModel inconsistent state.
  InconsistentStateError.viewModel(String message)
      : super(type: ErrorType.viewModelInconsistentState, message: message);

  /// Creates a new error to represent a layout inconsistent state.
  InconsistentStateError.layout(String message) : super(type: ErrorType.layoutInconsistentState, message: message);

  /// Creates a new error to represent a gateway inconsistent state.
  InconsistentStateError.gateway(String message) : super(type: ErrorType.gatewayInconsistentState, message: message);
}
