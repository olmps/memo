import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layoutr/common_layout.dart';

/// Provides utilities to elements that requires a responsive layout
///
/// Arguments:
///  - `double`: the width of the device.
// This `ScopedProvider` must be overriden in a `ProviderScope.overrides` before used
final layoutProvider = ScopedProvider<CommonLayout>(null);
