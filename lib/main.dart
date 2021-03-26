import 'package:flutter/material.dart';
import 'package:memo/application/app.dart';
import 'package:memo/application/view-models/app_vm.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final appVM = AppVM();
  runApp(AppRoot(appVM));
}
