import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memo/application/coordinator/routes.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';

/// Custom type-safe layer implementation for [Router] route parsing
///
/// See also:
///   - `RoutesCoordinator`, where all the heavy navigation management is handled;
///   - `CoordinatorRouterDelegate`, which intermediates the communication between the `RoutesCoordinator` and the OS.
class CoordinatorInformationParser extends RouteInformationParser<AppPath> {
  @override
  Future<AppPath> parseRouteInformation(RouteInformation routeInformation) async {
    final location = routeInformation.location;
    if (location != null) {
      return SynchronousFuture(parseRoute(location));
    }

    throw InconsistentStateError.coordinator('RouteInformation.location should never be null');
  }

  @override
  RouteInformation restoreRouteInformation(AppPath configuration) =>
      RouteInformation(location: configuration.formattedPath);
}
