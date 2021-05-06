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

/// Lazily updates the `LicenseRegistry` to include unspecified third party licenses
///
/// While flutter include all `pubspec` related licenses in the registry by default, there are a couple that are used
/// _indirectly_, thus needing to be added manually into the `LicenseRegistry`.
///
/// Also, this update is only actually called by the Flutter's framework when requested.
void addLicenseRegistryUpdater(AssetBundle bundle) {
  LicenseRegistry.addLicense(() async* {
    final licensesFutures = LicenseKey.values.map((license) => _generateLicense(bundle, license)).toList();
    yield* Stream.fromFutures(licensesFutures);
  });
}

Future<LicenseEntry> _generateLicense(AssetBundle bundle, LicenseKey key) async {
  final license = await bundle.loadString(key.path);
  return LicenseEntryWithLineBreaks([key.raw], license);
}
