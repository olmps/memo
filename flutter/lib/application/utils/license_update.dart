import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@visibleForTesting
enum LicenseKey {
  robotoMono,
}

extension RawLicenseKey on LicenseKey {
  @visibleForTesting
  String get raw {
    switch (this) {
      case LicenseKey.robotoMono:
        return 'RobotoMono';
    }
  }

  @visibleForTesting
  String get path => 'assets/licenses/$raw.txt';
}

/// Lazily updates `LicenseRegistry` to include unspecified third party licenses.
///
/// By default, flutter includes all `pubspec` licenses in the registry, though others that are used  _indirectly_ must
/// be added manually to the `LicenseRegistry`.
void addLicenseRegistryUpdater(AssetBundle bundle) {
  // Only called by the Flutter's framework when requested.
  LicenseRegistry.addLicense(() async* {
    final licensesFutures = LicenseKey.values.map((license) => _generateLicense(bundle, license)).toList();
    yield* Stream.fromFutures(licensesFutures);
  });
}

Future<LicenseEntry> _generateLicense(AssetBundle bundle, LicenseKey key) async {
  final license = await bundle.loadString(key.path);
  return LicenseEntryWithLineBreaks([key.raw], license);
}
