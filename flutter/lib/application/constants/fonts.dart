// Type-safe usage of font assets.
//
// All raw font families belong here and must be only accessed through this file.
import 'package:meta/meta.dart';

@visibleForTesting
enum FontKey {
  robotoMono,
}

extension RawFontKey on FontKey {
  @visibleForTesting
  String get rawFamily {
    switch (this) {
      case FontKey.robotoMono:
        return 'RobotoMono';
    }
  }
}

final robotoMono = FontKey.robotoMono.rawFamily;
