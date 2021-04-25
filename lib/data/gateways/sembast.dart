import 'dart:async';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

const _schemaVersion = 1;
const _dbName = 'memo_sembast.db';

/// Opens this application's [Database], creating a new one if nonexistent
Future<Database> openDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  // Make sure that the application documents directory exists
  await dir.create(recursive: true);

  final dbPath = path.join(dir.path, _dbName);

  return databaseFactoryIo.openDatabase(dbPath, version: _schemaVersion, onVersionChanged: applyMigrations);
}

@visibleForTesting
Future<void> applyMigrations(Database db, int oldVersion, int newVersion) async {
  // Call the necessary migrations in order
}

//
// Migrations
//

// Example:
// Future<void> migrateToVersion2(Database db) async {
//   final store = stringMapStoreFactory.store('storeThatNeedsMigration');
//   final updatableItemsFinder = Finder(filter: Filter.equals('myUpdatedField', 1));
//   await store.update(db, { 'myUpdatedField': 2 }, finder: updatableItemsFinder);
// }
