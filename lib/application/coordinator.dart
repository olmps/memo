import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/pages/home/home_page.dart';
import 'package:memo/application/pages/settings/settings_page.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';

final coordinatorProvider = Provider<RoutesCoordinator>(
  (ref) => RoutesCoordinator(navigatorKey: GlobalKey<NavigatorState>()),
);

/// Coordinates the logic of the visible [Page]s stack based on locations (or URIs)
///
/// This coordinator is built to handle one side of the two-way communication between [RoutesCoordinator] (this class,
/// the core logic) and [CoordinatorRouterDelegate] (OS navigation intentions), by providing type-safe locations through
/// [CoordinatorInformationParser] and [AppPath], with the objective to have complete control of Flutter's [Route] and
/// [Navigator].
class RoutesCoordinator extends ChangeNotifier {
  RoutesCoordinator({required this.navigatorKey})
      : _pages = [
          MaterialPage<dynamic>(
            child: const HomePage(bottomTab: HomeBottomTab.study),
            key: _homeKey,
            name: StudyPath().formattedPath,
          ),
        ];

  final GlobalKey<NavigatorState> navigatorKey;

  /// Shared key between the multiple home pages
  static const _homeKey = ValueKey('Home');

  /// Descending ordered (visibles come last) stack of visible/existing pages
  List<Page> get pages => List.unmodifiable(_pages);
  List<Page> _pages;

  /// The path respective to the the current visible page
  AppPath get currentPath => _parseRoute(currentRoute);

  /// Raw value for [currentPath]
  String get currentRoute {
    final currentRoute = _pages.last.name;

    if (currentRoute == null) {
      throw InconsistentStateError.coordinator('RoutesCoordinator list of pages was empty');
    }

    return currentRoute;
  }

  /// Notifies this coordinator to pop the [page]
  void didPop(Page page) {
    _pages.remove(page);
    notifyListeners();
  }

  /// Updates the current route to [path], making the required changes to the pages stack
  void setNewRoutePath(AppPath path) {
    if (path is HomePath) {
      // Any path inheriting HomePath should be considered as the root of our application, so when navigating to it, we
      // remove any other visible pages
      if (currentPath.formattedPath != path.formattedPath) {
        _pages = [];

        final HomeBottomTab homeTab;
        if (path is StudyPath) {
          homeTab = HomeBottomTab.study;
        } else if (path is ProgressPath) {
          homeTab = HomeBottomTab.progress;
        } else {
          throw InconsistentStateError.coordinator("Unsupported `HomeBottomTab` (with path '$path' for `HomePage`");
        }

        _addPage(HomePage(bottomTab: homeTab), name: path.formattedPath, customKey: _homeKey);
      } else {
        // Otherwise we simply remove all pages other than the matched one
        _pages.removeRange(1, _pages.length);
      }
    }

    if (path is SettingsPath) {
      _addPage(SettingsPage(), name: path.formattedPath);
    }

    notifyListeners();
  }

  /// Adds a new page to the top of the current stack (last in [_pages] list)
  ///
  /// - [isFullscreen] changes the type of navigation that this page is shown;
  /// - [customKey] overrides the custom key for this page (which is creating a `ValueKey` from the [name] argument).
  void _addPage(Widget widget, {required String name, bool isFullscreen = true, ValueKey<String>? customKey}) {
    final pageKey = customKey ?? ValueKey(name);

    // Usually, there can't be multiple pages with the same key in the pages stack. If this is the case, the usage of
    // `Key` to manage the existing pages must be reevaluated
    final pagesWithSameKey = _pages.where((page) => page.key == pageKey);
    if (pagesWithSameKey.isNotEmpty) {
      throw InconsistentStateError.coordinator(
        'No pages with the same keys are allowed. Page with the same key: $pagesWithSameKey',
      );
    }

    _pages.add(
      MaterialPage<dynamic>(child: widget, key: pageKey, name: name, fullscreenDialog: isFullscreen),
    );
  }

  /// Inserts a page in any position of the stack ([_pages] list)
  void _insertPage(Widget widget, {required int index, required String name}) {
    _pages.insert(
      index,
      MaterialPage<dynamic>(child: widget, key: ValueKey(name), name: name),
    );
  }

  /// Adds a generic path to the current stack
  void addRoute(AppPath path) {
    setNewRoutePath(path);
  }

  void navigateToStudy() {
    setNewRoutePath(StudyPath());
  }

  void navigateToProgress() {
    setNewRoutePath(ProgressPath());
  }

  void navigateToSettings() {
    setNewRoutePath(SettingsPath());
  }
}

/// Core class to glue our [RoutesCoordinator] to the [Router] ecosystem, in this case, the [RouterDelegate]
///
/// This delegate essentially connects our [RoutesCoordinator] implementation to the lifecycle of [Router], meaning that
/// we can intermediate all the [Router]/[Navigator] configuration through a single core class, the [RoutesCoordinator].
///
/// See also:
///   - [RoutesCoordinator], where all the heavy navigation management is handled;
///   - [CoordinatorInformationParser], which provides a type-safe way to parse [Router] locations.
class CoordinatorRouterDelegate extends RouterDelegate<AppPath>
    with
        ChangeNotifier, // ignore: prefer_mixin
        PopNavigatorRouterDelegateMixin<AppPath> {
  CoordinatorRouterDelegate(RoutesCoordinator coordinator) : _coordinator = coordinator {
    // Pass along any updates from the RouterDelegate to our coordinator, so we can keep things synchronized
    //
    // We also can't use providers (we have to store the coordinator and attach a manual listener) because we must use
    // it in methods other than build, like in `currentConfiguration` and `setNewRoutePath` overrides.
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

  @override
  Future<void> setInitialRoutePath(AppPath configuration) {
    // TODO(matuella): This doesn't seems right, but because we are passing our own `RouteInformationProvider` in the
    // root `MaterialApp`, this will be called once again, thus resetting the navigation.
    return SynchronousFuture(null);
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _coordinator.navigatorKey;

  @override
  AppPath get currentConfiguration => _coordinator.currentPath;

  @override
  Future<void> setNewRoutePath(AppPath configuration) => SynchronousFuture(_coordinator.setNewRoutePath(configuration));

  // `avoid_annotating_with_dynamic` conflicting with `implicit-dynamic`
  // ignore: avoid_annotating_with_dynamic
  bool _onPopPage(Route<dynamic> route, dynamic result) {
    final didPop = route.didPop(result);
    if (!didPop) {
      return false;
    }

    final routePage = route.settings;

    /// Can't forget to notify the RoutesCoordinator that the page was popped
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

/// Custom type-safe layer implementation for [Router] route parsing
///
/// See also:
///   - [RoutesCoordinator], where all the heavy navigation management is handled;
///   - [CoordinatorRouterDelegate], which intermediates the communication between the [RoutesCoordinator] and the OS.
class CoordinatorInformationParser extends RouteInformationParser<AppPath> {
  @override
  Future<AppPath> parseRouteInformation(RouteInformation routeInformation) async {
    final location = routeInformation.location;
    if (location != null) {
      return SynchronousFuture(_parseRoute(location));
    }

    throw InconsistentStateError.coordinator('RouteInformation.location should never be null');
  }

  @override
  RouteInformation restoreRouteInformation(AppPath configuration) =>
      RouteInformation(location: configuration.formattedPath);
}

/// Parses a raw [path] into a type-safe [AppPath]
AppPath _parseRoute(String path) {
  final pathUri = Uri.parse(path);

  // Forwards '/' to our "first home", as we don't have one route for a "base" path
  if (pathUri.pathSegments.isEmpty) {
    return StudyPath();
  }

  final firstSubPath = pathUri.pathSegments[0];

  // handle home-related tabs
  if (firstSubPath == StudyPath.name) {
    return StudyPath();
  }

  if (firstSubPath == ProgressPath.name) {
    return ProgressPath();
  }

  // handle '/settings' and related
  if (firstSubPath == SettingsPath.name) {
    return SettingsPath();
  }

  // Set a fallback to a page because web has this expected behavior of the user actively changing the URL
  return StudyPath();
}

/// Class responsible for storing typed information about
/// the current navigation path in the app
abstract class AppPath {
  String get formattedPath;
}

//
// Home
//
abstract class HomePath extends AppPath {}

class StudyPath extends HomePath {
  static const name = 'study';

  @override
  String get formattedPath => '/$name';
}

class ProgressPath extends HomePath {
  static const name = 'progress';

  @override
  String get formattedPath => '/$name';
}

//
// Settings
//
class SettingsPath extends AppPath {
  static const name = 'settings';

  @override
  String get formattedPath => '/$name';
}
