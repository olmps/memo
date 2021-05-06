import 'package:flutter_test/flutter_test.dart';
import 'package:memo/application/constants/fonts.dart';

import '../../utils/asset_manifest.dart' as asset;

void main() {
  test('All FontKey values should be available in assets folder', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final manifest = await asset.loadManifest();

    for (final fontKey in FontKey.values) {
      fontKey.supportedWeights
          .map((weight) => '${fontKey.path}-${_suffixForWeight(weight)}.${fontKey.fontType}')
          .toList()
          .forEach((path) => expect(manifest.keys.contains(path), isTrue));
    }
  });
}

extension on FontKey {
  String get fontType {
    switch (this) {
      case FontKey.robotoMono:
        return 'ttf';
    }
  }

  String get path => 'assets/fonts/$rawFamily';

  List<int> get supportedWeights {
    switch (this) {
      case FontKey.robotoMono:
        return [100, 200, 300, 400, 500, 600, 700];
    }
  }
}

/// Given our font naming guidelines, returns the respective suffix of a font [weight]
String _suffixForWeight(int weight) {
  switch (weight) {
    case 100:
      return 'Thin';
    case 200:
      return 'ExtraLight';
    case 300:
      return 'Light';
    case 400:
      return 'Regular';
    case 500:
      return 'Medium';
    case 600:
      return 'SemiBold';
    case 700:
      return 'Bold';
    case 800:
      return 'ExtraBold';
    case 900:
      return 'Black';
    default:
      throw ArgumentError.value(weight, 'weight', 'Unsupported font value');
  }
}
