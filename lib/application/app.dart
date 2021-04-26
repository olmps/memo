import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/spacings.dart';
import 'package:memo/application/coordinator/coordinator_information_parser.dart';
import 'package:memo/application/coordinator/coordinator_router_delegate.dart';
import 'package:memo/application/coordinator/routes_coordinator.dart';
import 'package:memo/application/pages/splash_page.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/view-models/app_vm.dart';

/// "Pre-load" root widget for the application
///
/// This widget is a wrapper to provide (and load) an instance of [AppState], while showing a splash screen while it's
/// loading for any external/internal dependencies.
class AppRoot extends StatelessWidget {
  const AppRoot(this.vm);
  final AppVM vm;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AsyncValue<AppState>>(
      valueListenable: vm,
      builder: (context, value, child) {
        return value.maybeWhen(
          data: (state) {
            return CommonLayoutWidget(
              spacings: spacings,
              child: ProviderScope(
                // Override all `Provider` and `ScopedProvider` that are late-initialized
                overrides: [
                  collectionServices.overrideWithValue(state.collectionServices),
                  executionServices.overrideWithValue(state.executionServices),
                  progressServices.overrideWithValue(state.progressServices),
                ],
                child: _LoadedAppRoot(),
              ),
            );
          },
          orElse: () => const MaterialApp(home: SplashPage()),
        );
      },
    );
  }
}

/// Loaded root widget for the application
///
/// After [AppRoot] is done with the loading, [_LoadedAppRoot] takes place (of the [SplashPage]) as the root of our
/// application (and have all late-initialized providers available to it).
class _LoadedAppRoot extends StatefulHookWidget {
  @override
  _LoadedAppRootState createState() => _LoadedAppRootState();
}

class _LoadedAppRootState extends State<_LoadedAppRoot> {
  PlatformRouteInformationProvider? _routeInformationParser;

  @override
  Widget build(BuildContext context) {
    final coordinator = context.read(coordinatorProvider);

    // Must keep stored the `PlatformRouteInformationProvider`, otherwise when this widget rebuilds (for any reason),
    // the current route will be reset to our "root". Not sure if this is the best approach, but this new Router API
    // sure is confusing.
    _routeInformationParser ??= PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(location: coordinator.currentRoute),
    );

    return MaterialApp.router(
      title: 'Memo',
      debugShowCheckedModeBanner: false,
      theme: useThemeController().currentThemeData(context),
      routerDelegate: CoordinatorRouterDelegate(coordinator),
      routeInformationParser: CoordinatorInformationParser(),
      routeInformationProvider: _routeInformationParser,
    );
  }
}
