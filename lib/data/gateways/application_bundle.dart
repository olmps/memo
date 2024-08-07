import 'dart:convert';

import 'package:flutter/services.dart';

/// Exposes **read** access to all application's assets.
abstract class ApplicationBundle {
  /// Loads a JSON stored in [path].
  Future<dynamic> loadJson(String path);

  /// Retrieves a list of all assets file-paths that start with [path].
  ///
  /// I.e.:
  /// ```
  /// - assets
  ///   - my_first_folder
  ///     - file1.json
  ///     - file2.png
  ///   - my_other_folder
  ///     - file3.json
  /// ```
  ///
  /// Calling `loadAssetsListPath('assets/my_first_folder')` would then return:
  /// ```
  /// [
  ///   'assets/my_first_folder/file1.json',
  ///   'assets/my_first_folder/file2.png',
  /// ]
  /// ```
  ///
  /// The same value above would work if we called `loadAssetsListPath` with `assets/my_first_folder/file`,
  /// `assets/my_first_folder/fil`, `assets/my_first_folder/fi` or even `assets/my_first_folder/f`.
  Future<List<String>> loadAssetsListPath(String path);
}

class ApplicationBundleImpl extends ApplicationBundle {
  ApplicationBundleImpl(this._assetBundle);
  final AssetBundle _assetBundle;

  /// Flutter's auto-generated file that provides info for all assets stored within the application.
  final String _assetsManifest = 'AssetManifest.json';

  @override
  Future<dynamic> loadJson(String path) async {
    final rawJson = await _assetBundle.loadString(path);
    return jsonDecode(rawJson);
  }

  @override
  Future<List<String>> loadAssetsListPath(String path) async {
    final rawManifest = await _assetBundle.loadString(_assetsManifest);
    final manifest = jsonDecode(rawManifest) as Map<String, dynamic>;
    return manifest.keys.where((key) => key.startsWith(path) && !key.contains('.DS_Store')).toList();
  }
}
