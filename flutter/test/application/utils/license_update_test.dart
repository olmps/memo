import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/utils/license_update.dart';

import '../../utils/asset_manifest.dart' as asset;
import '../../utils/widget_pump.dart';

void main() {
  test('All LicenseKey values should be available in assets folder', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final manifest = await asset.loadManifest();

    for (final licenseKey in LicenseKey.values) {
      expect(manifest.keys.contains(licenseKey.path), isTrue);
    }
  });

  testWidgets('Should load all license registries when required', (tester) async {
    final widget = Builder(
      builder: (context) {
        addLicenseRegistryUpdater(rootBundle);
        return const LicensePage();
      },
    );
    await pumpMaterialScoped(tester, widget);
    // Wait for all frames to be settled, because `LicensePage` loads asynchronously
    await tester.pumpAndSettle();

    for (final licenseKey in LicenseKey.values) {
      expect(find.text(licenseKey.raw), findsOneWidget);
    }
  });
}
