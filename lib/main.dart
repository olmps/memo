import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:memo/application/app.dart';
import 'package:memo/application/view-models/app_vm.dart';
import 'package:memo/core/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = envMetadata();

  await Firebase.initializeApp();
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!env.isDev);
  FlutterError.onError = crashlytics.recordFlutterError;

  // Wraps `AppRoot` in a guarded zone where all errors are reported to `crashlytics.recordError`.
  runZonedGuarded(
    () {
      final appVM = AppVMImpl();

      runApp(AppRoot(appVM));
    },
    crashlytics.recordError,
  );
}
