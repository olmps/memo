import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/coordinator/routes.dart';
import 'package:memo/application/pages/home/home_page.dart';
import 'package:memo/application/pages/settings/settings_page.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';

final coordinatorProvider = Provider<RoutesCoordinator>(
  (ref) => RoutesCoordinator(navigatorKey: GlobalKey<NavigatorState>()),
);

/// Coordinates the logic of the visible [Page]s stack based on locations (or URIs)
///
/// This coordinator is built to handle one side of the two-way communication between [RoutesCoordinator] (this class,
/// the core logic) and `CoordinatorRouterDelegate` (OS navigation intentions), by providing type-safe locations through
/// `CoordinatorInformationParser` and [AppPath], with the objective to have complete control of Flutter's [Route] and
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
  AppPath get currentPath => parseRoute(currentRoute);

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
  // ignore: unused_element
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
