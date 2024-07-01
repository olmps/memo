import 'dart:io';

import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:meta/meta.dart';

/// Application's configuration and metadata.
abstract class EnvMetadata {
  /// Current application environment.
  Env get env;

  /// Current application platform.
  SupportedPlatform get platform;

  /// `true` when running in [Env.dev].
  bool get isDev;

  /// RevenueCat SDK API Key.
  String get inAppPurchaseKey;
}

class EnvMetadataImpl implements EnvMetadata {
  EnvMetadataImpl(this.env);

  @override
  final Env env;

  @override
  bool get isDev => env == Env.dev;

  @override
  SupportedPlatform get platform {
    if (Platform.isIOS) {
      return SupportedPlatform.ios;
    } else if (Platform.isAndroid) {
      return SupportedPlatform.android;
    }

    throw InconsistentStateError('Unsupported platform - ${Platform.operatingSystem}');
  }

  @override
  String get inAppPurchaseKey {
    switch (platform) {
      case SupportedPlatform.ios:
        return 'appl_edKVhziuBuXDpmVPASASRdEJhKc';
      case SupportedPlatform.android:
        return 'goog_PlRbIRkgyhwGbBiUugCHBjzXsTL';
    }
  }
}

/// Application's supported environments.
enum Env { dev, prod }

/// Application's supported platforms.
enum SupportedPlatform { android, ios }

/// Retrieves the current environment metadata using environment arguments.
EnvMetadata envMetadata() {
  // ignore: do_not_use_environment
  const rawEnv = String.fromEnvironment('ENV');
  final env = parseEnv(rawEnv);

  return EnvMetadataImpl(env);
}

/// Parses a `raw` string to a [Env].
///
/// Throws an [InconsistentStateError] if [raw] doesn't match any pre-mapped [Env].
@visibleForTesting
Env parseEnv(String raw) {
  switch (raw) {
    case 'DEV':
      return Env.dev;
    case 'PROD':
      return Env.prod;
    default:
      throw InconsistentStateError('Unsupported raw environment of value "$raw"');
  }
}
