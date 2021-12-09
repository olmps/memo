import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/constants/images.dart';

import '../../utils/asset_manifest.dart' as asset;

void main() {
  test('All ImageKey values should be available in assets folder', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final manifest = await asset.loadManifest();

    for (final imageKey in ImageKey.values) {
      expect(manifest.keys.contains(imageKey.path), isTrue);
    }
  });
}
