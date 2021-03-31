import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/data/repositories/deck_repository.dart';
import 'package:memo/domain/services/deck_services.dart';
import 'package:memo/data/gateways/document_database_gateway.dart';
import 'package:memo/data/gateways/sembast_database.dart' as sembast_db;
import 'package:sembast/sembast.dart';

/// Manages all app asynchronous dependencies
///
/// This is where we glue all nested interdependencies that will be used through the whole application's lifecycle.
///
/// Ideally, this should also be a provider (a [FutureProvider]), but because we cannot override providers (non
/// [ScopedProvider]) that aren't in a root [ProviderScope], we fall back to a more vanilla implementation, using the
/// [ValueNotifier], provided by the `flutter/foundation` library.
///
/// When resolving the future, returns all required dependencies through an [AppState] instance
abstract class AppVM extends ValueNotifier<AsyncValue<AppState>> {
  AppVM(AsyncValue<AppState> value) : super(value);
}

class AppVMImpl extends AppVM {
  AppVMImpl() : super(const AsyncValue.loading()) {
    _loadAppVM();
  }

  /// Requests this instance to load all of its dependencies
  Future<void> _loadAppVM() async {
    const splashMinDuration = Duration(milliseconds: 500);
    final dependencies = await Future.wait<dynamic>([
      sembast_db.openDatabase(),
      // Set a minimum (reasonable) duration for this first load, as it may simply flick a splash screen if too fast
      Future<dynamic>.delayed(splashMinDuration),
    ]);

    // Ideally, we shouldn't let a Data layer component be instantiated in an application component (VM), but due to how
    // all "state-management" libraries work (in response to Flutter's widget-centric design), it's almost impossible to
    // not attach application-wide dependencies into the widget's tree, meaning: at some point, the UI will have to know
    // about these classes and, in our case, river_pod is not different. What we are - currently - leaking:
    // - Services to UI: we need all services to override the default null value of its `Provider` in the root
    // `ProviderScope`. This is because all data-related dependencies are async. While we could make all of our services
    // `FutureProvider`, it would generate a significant boilerplate throughout all the application.
    //
    // All of these needs a late initialization due to runtime dependencies, which we will only know after some async
    // initialization.

    final dbRepo = SembastGateway(dependencies[0] as Database);
    final decksRepo = DeckRepositoryImpl(dbRepo);
    final deckServices = DeckServicesImpl(decksRepo);

    value = AsyncValue.data(AppState(deckServices: deckServices));
  }
}

class AppState {
  const AppState({required this.deckServices});
  final DeckServices deckServices;
}
