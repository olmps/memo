// Type-safe usage of images assets.
//
// All raw images paths belong here and must be only accessed through this file.
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:meta/meta.dart';

const _imgsRoot = 'assets/images';

@visibleForTesting
enum ImageKey {
  // icons
  addCircle,
  bold,
  chevronLeft,
  chevronRight,
  code,
  close,
  clear,
  drag,
  folder,
  italic,
  link,
  organize,
  settings,
  trash,
  trendingUpArrow,
  underline,

  // illustrations
  easyEmoji,
  folderBig,
  hardEmoji,
  logo,
  mediumEmoji,
  userAvatar,
}

extension ImageKeyPath on ImageKey {
  @visibleForTesting
  String get path {
    switch (this) {
      case ImageKey.addCircle:
        return '$_illustrationsRoot/add_circle.png';
      case ImageKey.bold:
        return '$_editorIconsRoot/bold.png';
      case ImageKey.code:
        return '$_editorIconsRoot/code.png';
      case ImageKey.chevronLeft:
        return '$_iconsRoot/chevron_left.png';
      case ImageKey.chevronRight:
        return '$_iconsRoot/chevron_right.png';
      case ImageKey.close:
        return '$_iconsRoot/close.png';
      case ImageKey.clear:
        return '$_iconsRoot/clear.png';
      case ImageKey.drag:
        return '$_iconsRoot/drag.png';
      case ImageKey.folder:
        return '$_iconsRoot/folder.png';
      case ImageKey.italic:
        return '$_editorIconsRoot/italic.png';
      case ImageKey.link:
        return '$_iconsRoot/link.png';
      case ImageKey.organize:
        return '$_iconsRoot/organize.png';
      case ImageKey.settings:
        return '$_iconsRoot/settings.png';
      case ImageKey.trash:
        return '$_iconsRoot/trash.png';
      case ImageKey.trendingUpArrow:
        return '$_iconsRoot/trending_up_arrow.png';
      case ImageKey.underline:
        return '$_editorIconsRoot/underline.png';
      case ImageKey.easyEmoji:
        return '$_illustrationsRoot/easy_emoji.png';
      case ImageKey.folderBig:
        return '$_illustrationsRoot/folder_big.png';
      case ImageKey.hardEmoji:
        return '$_illustrationsRoot/hard_emoji.png';
      case ImageKey.logo:
        return '$_illustrationsRoot/logo.png';
      case ImageKey.mediumEmoji:
        return '$_illustrationsRoot/medium_emoji.png';
      case ImageKey.userAvatar:
        return '$_illustrationsRoot/user_avatar.png';
    }
  }
}

const _iconsRoot = '$_imgsRoot/icons';
const _editorIconsRoot = '$_iconsRoot/editor';
final addCircleAsset = ImageKey.addCircle.path;
final boldAsset = ImageKey.bold.path;
final chevronLeftAsset = ImageKey.chevronLeft.path;
final chevronRightAsset = ImageKey.chevronRight.path;
final codeAsset = ImageKey.code.path;
final closeAsset = ImageKey.close.path;
final clearAsset = ImageKey.clear.path;
final dragAsset = ImageKey.drag.path;
final folderAsset = ImageKey.folder.path;
final italicAsset = ImageKey.italic.path;
final linkAsset = ImageKey.link.path;
final organizeAsset = ImageKey.organize.path;
final settingsAsset = ImageKey.settings.path;
final trashAsset = ImageKey.trash.path;
final trendingUpArrowAsset = ImageKey.trendingUpArrow.path;
final underlineAsset = ImageKey.underline.path;

const _illustrationsRoot = '$_imgsRoot/illustrations';
final easyEmojiAsset = ImageKey.easyEmoji.path;
final folderBigAsset = ImageKey.folderBig.path;
final hardEmojiAsset = ImageKey.hardEmoji.path;
final logoAsset = ImageKey.logo.path;
final mediumEmojiAsset = ImageKey.mediumEmoji.path;
final userAvatarAsset = ImageKey.userAvatar.path;

String memoDifficultyEmoji(MemoDifficulty difficulty) {
  switch (difficulty) {
    case MemoDifficulty.easy:
      return easyEmojiAsset;
    case MemoDifficulty.medium:
      return mediumEmojiAsset;
    case MemoDifficulty.hard:
      return hardEmojiAsset;
  }
}
