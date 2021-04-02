import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/gateways/document_database_gateway.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  final fakeObject = {'fake': 'fake'};
  const fakeRecordId = 'a-fake-id';
  const fakeStore = 'fake_store';
  final fakeRecord = stringMapStoreFactory.store(fakeStore).record(fakeRecordId);

  late Database memorySembast;
  late DocumentDatabaseGateway db;

  setUp(() async {
    await databaseFactoryMemory.deleteDatabase('test.db');
    memorySembast = await databaseFactoryMemory.openDatabase('test.db');
    db = SembastGateway(memorySembast);
  });

  test('DatabaseRepositoryImpl should put a new object', () async {
    expect(await fakeRecord.get(memorySembast), null);

    await db.put(id: fakeRecordId, object: fakeObject, store: fakeStore);

    expect(await fakeRecord.get(memorySembast), fakeObject);
  });

  test('DatabaseRepositoryImpl should update an existing object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final fakeUpdatedObject = {'fake': 'fakeUpdated', 'newFake': 'fake'};

    await db.put(id: fakeRecordId, object: fakeUpdatedObject, store: fakeStore);

    expect(await fakeRecord.get(memorySembast), fakeUpdatedObject);
  });

  test('DatabaseRepositoryImpl should remove pre-existing fields in an update without merge', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final fakeUpdatedObject = {'newFake': 'fake'};

    await db.put(id: fakeRecordId, object: fakeUpdatedObject, store: fakeStore, shouldMerge: false);

    expect(await fakeRecord.get(memorySembast), fakeUpdatedObject);
  });

  test('DatabaseRepositoryImpl should maintain pre-existing fields in an update with merge', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final fakeUpdatedObject = {'newFake': 'fake'};

    await db.put(id: fakeRecordId, object: fakeUpdatedObject, store: fakeStore);

    fakeUpdatedObject.addAll(fakeObject);
    expect(await fakeRecord.get(memorySembast), fakeUpdatedObject);
  });

  test('DatabaseRepositoryImpl should remove an existing object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    expect(await fakeRecord.get(memorySembast), fakeObject);
    await db.remove(id: fakeRecordId, store: fakeStore);
    expect(await fakeRecord.get(memorySembast), null);
  });

  test('DatabaseRepositoryImpl should do nothing when removing a nonexistent object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    await db.remove(id: fakeRecordId, store: fakeStore);
    expect(await fakeRecord.get(memorySembast), null);
  });

  test('DatabaseRepositoryImpl should retrieve a single existing object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final object = await db.get(id: fakeRecordId, store: fakeStore);
    expect(object, isNotNull);
  });

  test('DatabaseRepositoryImpl should get null when retrieving a single nonexistent object', () async {
    final object = await db.get(id: fakeRecordId, store: fakeStore);
    expect(object, null);
  });

  test('DatabaseRepositoryImpl should retrieve multiple objects', () async {
    await fakeRecord.put(memorySembast, fakeObject);
    await stringMapStoreFactory.store(fakeStore).record('2').put(memorySembast, fakeObject);

    final objects = await db.getAll(store: fakeStore);
    expect(objects.length, 2);
  });

  test('DatabaseRepositoryImpl should retrieve an empty list if there is no objects in the store', () async {
    final objects = await db.getAll(store: fakeStore);
    expect(objects.isEmpty, true);
  });

  // TODO(matuella): Find a way to test the listenAll
}
