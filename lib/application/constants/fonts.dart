import 'package:meta/meta.dart';

// This file gives us a - somewhat - more type-safe usage of font assets
// All raw font families belong here and must be only accessed through this file.

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
