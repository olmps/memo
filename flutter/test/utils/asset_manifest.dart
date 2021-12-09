import 'dart:convert';

import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadManifest() async {
  final rawManifest = await rootBundle.loadString('AssetManifest.json');
  return jsonDecode(rawManifest) as Map<String, dynamic>;
}
