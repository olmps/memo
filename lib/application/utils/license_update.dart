import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Updates the `LicenseRegistry` to include unspecified third party licenses
///
/// While flutter include all `pubspec` related licenses in the registry by default, there are a couple that are used
/// _indirectly_, thus needing to be added manually into the `LicenseRegistry`.
void updateLicenseRegistry() {
  LicenseRegistry.addLicense(() async* {
    const robotoMonoLicense = 'fonts/RobotoMono-LICENSE.txt';
    final license = await rootBundle.loadString(robotoMonoLicense);

    yield LicenseEntryWithLineBreaks(['RobotoMono'], license);
  });
}
