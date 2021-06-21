import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memo/application/app.dart';
import 'package:memo/application/view-models/app_vm.dart';
import 'package:memo/data/repositories/analytics_monitor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final appVM = AppVMImpl();

  runZonedGuarded(() {
    runApp(AppRoot(appVM));
  }, AnalyticsMonitorImpl.instance.recordZoneError);
}
