import 'dart:io';

import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:meta/meta.dart';

/// Application's configuration and metadata
abstract class EnvMetadata {
  /// Current application environment
  Env get env;

  /// Current application platform
  SupportedPlatform get platform;

  /// Utility that is `true` when running in [Env.dev]
  bool get isDev;
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
}

/// Application's supported environments
enum Env { dev, prod }

/// Application's supported platforms
enum SupportedPlatform { android, ios }

/// Retrieves the current environment metadata using the environment arguments
EnvMetadata envMetadata() {
  // ignore: do_not_use_environment
  const rawEnv = String.fromEnvironment('ENV');
  final env = parseEnv(rawEnv);

  return EnvMetadataImpl(env);
}

/// Parses a `raw` string to a [Env].
///
/// If the `raw` parameter doesn't match any pre-mapped [Env], an [InconsistentStateError] is thrown.
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
