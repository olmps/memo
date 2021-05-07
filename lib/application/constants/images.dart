import 'package:meta/meta.dart';

// This file gives us a - somewhat - more type-safe usage of images assets
// All raw images paths belong here and must be only accessed through this file.

const _imgsRoot = 'assets/images';

@visibleForTesting
enum ImageKey {
  // icons
  chevronLeft,
  chevronRight,
  close,
  folder,
  link,
  settings,
  trendingUpArrow,

  // illustrations
  logo,
}

extension ImageKeyPath on ImageKey {
  @visibleForTesting
  String get path {
    switch (this) {
      case ImageKey.chevronLeft:
        return '$_iconsRoot/chevron_left.png';
      case ImageKey.chevronRight:
        return '$_iconsRoot/chevron_right.png';
      case ImageKey.close:
        return '$_iconsRoot/close.png';
      case ImageKey.folder:
        return '$_iconsRoot/folder.png';
      case ImageKey.link:
        return '$_iconsRoot/link.png';
      case ImageKey.settings:
        return '$_iconsRoot/settings.png';
      case ImageKey.trendingUpArrow:
        return '$_iconsRoot/trending_up_arrow.png';
      case ImageKey.logo:
        return '$_illustrationsRoot/logo.png';
    }
  }
}

const _iconsRoot = '$_imgsRoot/icons';
final chevronLeftAsset = ImageKey.chevronLeft.path;
final chevronRightAsset = ImageKey.chevronRight.path;
final closeAsset = ImageKey.close.path;
final folderAsset = ImageKey.folder.path;
final linkAsset = ImageKey.link.path;
final settingsAsset = ImageKey.settings.path;
final trendingUpArrowAsset = ImageKey.trendingUpArrow.path;

const _illustrationsRoot = '$_imgsRoot/illustrations';
final logoAsset = ImageKey.logo.path;
