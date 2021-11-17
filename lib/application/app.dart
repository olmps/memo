import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layoutr/common_layout.dart';
import 'package:memo/application/constants/spacings.dart';
import 'package:memo/application/coordinator/coordinator_information_parser.dart';
import 'package:memo/application/coordinator/coordinator_router_delegate.dart';
import 'package:memo/application/coordinator/routes_coordinator.dart';
import 'package:memo/application/pages/splash_page.dart';
import 'package:memo/application/theme/theme_controller.dart';
import 'package:memo/application/utils/license_update.dart';
import 'package:memo/application/utils/scaffold_messenger.dart';
import 'package:memo/application/view-models/app_vm.dart';

/// "Pre-load" root widget for the application.
///
/// A wrapper that loads and injects all dependencies using [AppVM].
class AppRoot extends StatelessWidget {
  const AppRoot(this.vm);
  final AppVM vm;

  @override
  Widget build(BuildContext context) {
    final bundle = DefaultAssetBundle.of(context);
    vm.loadDependencies(bundle);
    addLicenseRegistryUpdater(bundle);

    return ValueListenableBuilder<AsyncValue<AppState>>(
      valueListenable: vm,
      builder: (context, value, child) {
        return value.maybeWhen(
          data: (state) {
            return CommonLayoutWidget(
              spacings: spacings,
              child: ProviderScope(
                // Override all `Provider` and `ScopedProvider` that are late-initialized.
                overrides: [
                  collectionServices.overrideWithValue(state.collectionServices),
                  executionServices.overrideWithValue(state.executionServices),
                  progressServices.overrideWithValue(state.progressServices),
                  resourceServices.overrideWithValue(state.resourceServices),
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

/// Loaded root widget for the application.
///
/// After [AppRoot] is done loading, [_LoadedAppRoot] takes place (of the [SplashPage]) as the root of our application,
/// with all injected dependencies.
class _LoadedAppRoot extends ConsumerStatefulWidget {
  @override
  ConsumerState createState() => _LoadedAppRootState();
}

class _LoadedAppRootState extends ConsumerState<_LoadedAppRoot> {
  PlatformRouteInformationProvider? _routeInformationParser;

  @override
  Widget build(BuildContext context) {
    final coordinator = readCoordinator(ref);

    // Store `PlatformRouteInformationProvider`, otherwise when this widget rebuilds (for any reason), the current route
    // will be reset to "root". Not sure if this is the best approach.
    _routeInformationParser ??= PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(location: coordinator.currentRoute),
    );

    return MaterialApp.router(
      scaffoldMessengerKey: ref.watch(scaffoldMessenger),
      title: 'Memo',
      debugShowCheckedModeBanner: false,
      theme: ref.watch(themeController.notifier).currentThemeData(context),
      routerDelegate: CoordinatorRouterDelegate(coordinator),
      routeInformationParser: CoordinatorInformationParser(),
      routeInformationProvider: _routeInformationParser,
    );
  }
}
