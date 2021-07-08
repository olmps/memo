import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memo/application/coordinator/routes.dart';
import 'package:memo/application/coordinator/routes_coordinator.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';

/// Core class that glues our [RoutesCoordinator] to flutter's [Router]/[Navigator] lifecycles, using the
/// [RouterDelegate].
///
/// See also:
///   - [RoutesCoordinator], where all the heavy navigation management is handled.
///   - `CoordinatorInformationParser`, providing a type-safe way to parse [Router] locations.
class CoordinatorRouterDelegate extends RouterDelegate<AppPath>
    with
        ChangeNotifier, // ignore: prefer_mixin
        PopNavigatorRouterDelegateMixin<AppPath> {
  CoordinatorRouterDelegate(RoutesCoordinator coordinator) : _coordinator = coordinator {
    // Pass along any updates from the RouterDelegate to our coordinator, so we can keep things synchronized.
    //
    // Can't use providers (have to store the coordinator and attach a manual listener) because it must be called in
    // methods other than build, like in `currentConfiguration` and `setNewRoutePath` overrides.
    _coordinator.addListener(notifyListeners);
  }

  final RoutesCoordinator _coordinator;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: _coordinator.pages,
    );
  }

  // Ignore calls to this method, as `RouteInformationProvider` should be directly injected in the root `MaterialApp`.
  @override
  Future<void> setInitialRoutePath(AppPath configuration) => SynchronousFuture(null);

  @override
  GlobalKey<NavigatorState> get navigatorKey => _coordinator.navigatorKey;

  @override
  AppPath get currentConfiguration => _coordinator.currentPath;

  @override
  Future<void> setNewRoutePath(AppPath configuration) => SynchronousFuture(_coordinator.setNewRoutePath(configuration));

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    final didPop = route.didPop(result);
    if (!didPop) {
      return false;
    }

    final routePage = route.settings;

    // Can't forget to notify the RoutesCoordinator that the page was popped
    if (routePage is Page) {
      _coordinator.didPop(routePage);
    } else {
      throw InconsistentStateError.coordinator(
        'RouteSettings shoul be a subtype of `Page` - received type: ${routePage.runtimeType}',
      );
    }

    return true;
  }
}
