import 'package:memo/data/gateways/application_bundle.dart';

/// Handles all read, write and serialization operations pertaining to this application's versioning
abstract class VersionRepository {
  /// Retrieves a map that associated a `Collection` name as its key and its version as the value
  Future<Map<String, int>> getLocalCollectionVersions();
}

class VersionRepositoryImpl implements VersionRepository {
  VersionRepositoryImpl(this._appBundle);
  final ApplicationBundle _appBundle;
  static const _versionFile = 'assets/collections/_version.json';

  @override
  Future<Map<String, int>> getLocalCollectionVersions() async {
    final dynamic versionsJson = await _appBundle.loadJson(_versionFile);

    return Map<String, int>.from(versionsJson as Map<String, dynamic>);
  }
}
