import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/data/gateways/application_bundle.dart';
import 'package:memo/data/repositories/collection_repository.dart';
import 'package:memo/data/repositories/memo_execution_repository.dart';
import 'package:memo/data/repositories/memo_repository.dart';
import 'package:memo/data/repositories/resource_repository.dart';
import 'package:memo/data/repositories/transaction_handler.dart';
import 'package:memo/data/repositories/user_repository.dart';
import 'package:memo/data/repositories/version_repository.dart';
import 'package:memo/domain/isolated_services/memory_recall_services.dart';
import 'package:memo/domain/services/collection_services.dart';
import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/gateways/sembast.dart' as sembast;
import 'package:memo/domain/services/execution_services.dart';
import 'package:memo/domain/services/progress_services.dart';
import 'package:memo/domain/services/resource_services.dart';
import 'package:memo/domain/services/user_services.dart';
import 'package:memo/domain/services/version_services.dart';
import 'package:sembast/sembast.dart';

/// Manages all app asynchronous dependencies
///
/// This is where we glue all nested interdependencies that will be used through the whole application's lifecycle.
///
/// Ideally, this should also be a provider (a [FutureProvider]), but because we cannot override providers (non
/// [ScopedProvider]) that aren't in a root [ProviderScope], we fall back to a more vanilla implementation, using the
/// [ValueNotifier], provided by the `flutter/foundation` library.
abstract class AppVM extends ValueNotifier<AsyncValue<AppState>> {
  AppVM(AsyncValue<AppState> value) : super(value);

  /// Request all dependencies to load themselves and build the according [AppState]
  ///
  /// When resolving the future, returns all required dependencies through an [AppState] instance
  Future<void> loadDependencies(AssetBundle assetBundle);
}

class AppVMImpl extends AppVM {
  AppVMImpl() : super(const AsyncValue.loading());

  /// Manages if the dependencies have already been requested to load
  var _hasRequestedLoading = false;

  /// Requests this instance to load all of its dependencies
  @override
  Future<void> loadDependencies(AssetBundle assetBundle) async {
    // Ignore any subsequent calls after the first one has already been fired
    if (_hasRequestedLoading) {
      return;
    }
    _hasRequestedLoading = true;

    // Set a minimum (reasonable) duration for this first load, as it may simply flick a splash screen if too fast
    final splashMinDuration = Future<dynamic>.delayed(const Duration(milliseconds: 500));

    // Run all isolate dependencies, which are required by most of the application's core services/repositories
    final firstClassDependencies = await Future.wait<dynamic>([
      sembast.openDatabase(),
    ]);

    // Ideally, we shouldn't let a Data and Domain layers components be instantiated in an application component (VM), but due to how
    // all "state-management" libraries work (in response to Flutter's widget-centric design), it's almost impossible to
    // not attach application-wide dependencies into the widget's tree, meaning: at some point, the UI will have to know
    // about these classes and, in our case, river_pod is not different. What we are - currently - leaking:
    // - Services to UI: we need all services to override the default null value of its `Provider` in the root
    // `ProviderScope`. This is because all data-related dependencies are async. While we could make all of our services
    // `FutureProvider`, it would generate a significant boilerplate throughout all the application.
    //
    // All of these needs a late initialization due to runtime dependencies, which we will only know after some async
    // initialization.

    // Gateways
    final dbRepo = SembastDatabaseImpl(firstClassDependencies[0] as Database);
    final appBundle = ApplicationBundleImpl(assetBundle);

    // Repositories
    final collectionRepo = CollectionRepositoryImpl(dbRepo, appBundle);
    final memoRepo = MemoRepositoryImpl(dbRepo);
    final memoExecutionRepo = MemoExecutionRepositoryImpl(dbRepo);
    final userRepo = UserRepositoryImpl(dbRepo);
    final versionRepo = VersionRepositoryImpl(dbRepo);
    final resourceRepo = ResourceRepositoryImpl(dbRepo, appBundle);

    final transactionHandler = TransactionHandlerImpl(dbRepo);

    // Isolated Services
    final memoryServices = MemoryRecallServicesImpl();

    // Services
    final collectionServices = CollectionServicesImpl(
      collectionRepo: collectionRepo,
      memoRepo: memoRepo,
      memoryServices: memoryServices,
    );

    final executionServices = ExecutionServicesImpl(
      userRepo: userRepo,
      memoRepo: memoRepo,
      collectionRepo: collectionRepo,
      executionsRepo: memoExecutionRepo,
      memoryServices: memoryServices,
      transactionHandler: transactionHandler,
    );

    final progressServices = ProgressServicesImpl(userRepo: userRepo);

    final resourceServices = ResourceServicesImpl(resourceRepo);

    final appState = AppState(
      collectionServices: collectionServices,
      executionServices: executionServices,
      progressServices: progressServices,
      resourceServices: resourceServices,
    );

    // Scope-specific Services
    final versionServices = VersionServicesImpl(
      versionRepo: versionRepo,
      collectionRepo: collectionRepo,
      memoRepo: memoRepo,
      resourceRepo: resourceRepo,
    );

    final userServices = UserServicesImpl(userRepo);

    // Then run all "dependent dependencies", which are required for the application to work properly
    await Future.wait<dynamic>([
      versionServices.updateDependenciesIfNeeded(),
      userServices.createUserIfNeeded(),
      splashMinDuration,
    ]);

    value = AsyncValue.data(appState);
  }
}

class AppState {
  const AppState({
    required this.collectionServices,
    required this.executionServices,
    required this.progressServices,
    required this.resourceServices,
  });

  final CollectionServices collectionServices;
  final ExecutionServices executionServices;
  final ProgressServices progressServices;
  final ResourceServices resourceServices;
}

// Creates uninitialized Provider for all services, which MUST BE overriden in the root `ProviderScope.overrides`
final collectionServices = Provider<CollectionServices>((_) {
  throw UnimplementedError('collectionServices Provider must be overridden');
});
final executionServices = Provider<ExecutionServices>((_) {
  throw UnimplementedError('executionServices Provider must be overridden');
});
final progressServices = Provider<ProgressServices>((_) {
  throw UnimplementedError('progressServices Provider must be overridden');
});
final resourceServices = Provider<ResourceServices>((_) {
  throw UnimplementedError('resourceServices Provider must be overridden');
});
