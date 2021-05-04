import 'dart:convert';

import 'package:flutter/services.dart';

/// Exposes read access to all application-specific assets
abstract class ApplicationBundle {
  /// Loads a JSON stored in [path]
  Future<dynamic> loadJson(String path);
}

class ApplicationBundleImpl extends ApplicationBundle {
  ApplicationBundleImpl(this._assetBundle);
  final AssetBundle _assetBundle;

  @override
  Future<dynamic> loadJson(String path) async {
    final rawJson = await _assetBundle.loadString(path);
    return jsonDecode(rawJson);
  }
}
