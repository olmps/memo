import 'package:memo/data/gateways/sembast_database.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Handles all IO and serialization operations associated with the application's versioning
abstract class VersionRepository {
  /// Retrieves the latest application version.
  Future<String> getCurrentApplicationVersion();

  /// Retrieves the last stored application version.
  ///
  /// Returns `null` if the application version was never stored before.
  Future<String?> getStoredApplicationVersion();

  /// Uses the current application version to update the stored application version.
  ///
  /// A helper to simply call [getCurrentApplicationVersion] and store its returning value.
  Future<void> updateToLatestApplicationVersion();
}

class VersionRepositoryImpl implements VersionRepository {
  VersionRepositoryImpl(this._db);

  final SembastDatabase _db;
  final _mainStore = '';
  final _metadataRecord = 'application_metadata';
  final _metadataVersionKey = 'version';

  @override
  Future<String> getCurrentApplicationVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    return version + buildNumber;
  }

  @override
  Future<String?> getStoredApplicationVersion() async {
    final appMetadata = await _db.get(id: _metadataRecord, store: _mainStore);
    final dynamic appVersion = appMetadata?[_metadataVersionKey];
    return appVersion != null ? appVersion as String : null;
  }

  @override
  Future<void> updateToLatestApplicationVersion() async => _db.put(
        id: _metadataRecord,
        object: <String, String>{
          _metadataVersionKey: await getCurrentApplicationVersion(),
        },
        store: _mainStore,
      );
}
