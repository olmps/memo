/// Parses a raw [path] into a type-safe [AppPath]
AppPath parseRoute(String path) {
  final pathUri = Uri.parse(path);

  // Forwards '/' to our "first home", as we don't have one route for a "base" path
  if (pathUri.pathSegments.isEmpty) {
    return StudyPath();
  }

  final firstSubPath = pathUri.pathSegments[0];

  // handle home-related tabs
  if (firstSubPath == StudyPath.name) {
    return StudyPath();
  }

  if (firstSubPath == ProgressPath.name) {
    return ProgressPath();
  }

  // handle '/settings' and related
  if (firstSubPath == SettingsPath.name) {
    return SettingsPath();
  }

  // Set a fallback to a page because web has this expected behavior of the user actively changing the URL
  return StudyPath();
}

/// Class responsible for storing typed information about
/// the current navigation path in the app
abstract class AppPath {
  String get formattedPath;
}

//
// Home
//
abstract class HomePath extends AppPath {}

class StudyPath extends HomePath {
  static const name = 'study';

  @override
  String get formattedPath => '/$name';
}

class ProgressPath extends HomePath {
  static const name = 'progress';

  @override
  String get formattedPath => '/$name';
}

//
// Settings
//
class SettingsPath extends AppPath {
  static const name = 'settings';

  @override
  String get formattedPath => '/$name';
}
