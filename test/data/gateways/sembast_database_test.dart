import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/gateways/sembast_database.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  final fakeObject = {'fake': 'fake'};
  const fakeRecordId = 'a-fake-id';
  const fakeRawStore = 'fake_store';
  final fakeStore = stringMapStoreFactory.store(fakeRawStore);
  final fakeRecord = fakeStore.record(fakeRecordId);

  late Database memorySembast;
  late SembastDatabase db;

  setUp(() async {
    await databaseFactoryMemory.deleteDatabase('test.db');
    memorySembast = await databaseFactoryMemory.openDatabase('test.db');
    db = SembastDatabaseImpl(memorySembast);
  });

  test('DatabaseRepositoryImpl should put a new object', () async {
    expect(await fakeRecord.get(memorySembast), isNull);

    await db.put(id: fakeRecordId, object: fakeObject, store: fakeRawStore);

    expect(await fakeRecord.get(memorySembast), fakeObject);
  });

  test('DatabaseRepositoryImpl should put multiple objects at once', () async {
    expect(await fakeRecord.get(memorySembast), isNull);

    final records = [fakeRecordId, 'second-$fakeRecordId'];
    final fakeObjects = [fakeObject, fakeObject];
    await db.putAll(ids: records, objects: fakeObjects, store: fakeRawStore);

    expect(await fakeStore.records(records).get(memorySembast), fakeObjects);
  });

  test('DatabaseRepositoryImpl should update an existing object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final fakeUpdatedObject = {'fake': 'fakeUpdated', 'newFake': 'fake'};

    await db.put(id: fakeRecordId, object: fakeUpdatedObject, store: fakeRawStore);

    expect(await fakeRecord.get(memorySembast), fakeUpdatedObject);
  });

  test('DatabaseRepositoryImpl should remove pre-existing fields in an update without merge', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final fakeUpdatedObject = {'newFake': 'fake'};

    await db.put(id: fakeRecordId, object: fakeUpdatedObject, store: fakeRawStore, shouldMerge: false);

    expect(await fakeRecord.get(memorySembast), fakeUpdatedObject);
  });

  test('DatabaseRepositoryImpl should maintain pre-existing fields in an update with merge', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final fakeUpdatedObject = {'newFake': 'fake'};

    await db.put(id: fakeRecordId, object: fakeUpdatedObject, store: fakeRawStore);

    fakeUpdatedObject.addAll(fakeObject);
    expect(await fakeRecord.get(memorySembast), fakeUpdatedObject);
  });

  test('DatabaseRepositoryImpl should remove an existing object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    expect(await fakeRecord.get(memorySembast), fakeObject);
    await db.remove(id: fakeRecordId, store: fakeRawStore);
    expect(await fakeRecord.get(memorySembast), isNull);

    expect(await fakeRecord.get(memorySembast), isNull);
  });

  test('DatabaseRepositoryImpl should remove multiple existing objects at once', () async {
    final records = [fakeRecordId, 'second-$fakeRecordId'];
    final fakeObjects = [fakeObject, fakeObject];
    await fakeStore.records(records).put(memorySembast, fakeObjects);

    expect(await fakeStore.records(records).get(memorySembast), fakeObjects);
    await db.removeAll(ids: records, store: fakeRawStore);

    expect(await fakeStore.find(memorySembast), const <dynamic>[]);
  });

  test('DatabaseRepositoryImpl should do nothing when removing a nonexistent object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    await db.remove(id: fakeRecordId, store: fakeRawStore);
    expect(await fakeRecord.get(memorySembast), isNull);
  });

  test('DatabaseRepositoryImpl should retrieve a single existing object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final object = await db.get(id: fakeRecordId, store: fakeRawStore);
    expect(object, isNotNull);
  });

  test('DatabaseRepositoryImpl should retrieve multiple existing objects by their ids', () async {
    final records = [fakeRecordId, 'second-$fakeRecordId'];
    final fakeObjects = [fakeObject, fakeObject];
    await fakeStore.records(records).put(memorySembast, fakeObjects);

    final objects = await db.getAllByIds(ids: records, store: fakeRawStore);
    expect(objects, fakeObjects);
  });

  test('DatabaseRepositoryImpl should get null when retrieving a single nonexistent object', () async {
    final object = await db.get(id: fakeRecordId, store: fakeRawStore);
    expect(object, isNull);
  });

  test('DatabaseRepositoryImpl should retrieve multiple objects', () async {
    await fakeRecord.put(memorySembast, fakeObject);
    await stringMapStoreFactory.store(fakeRawStore).record('2').put(memorySembast, fakeObject);

    final objects = await db.getAll(store: fakeRawStore);
    expect(objects.length, 2);
  });

  test('DatabaseRepositoryImpl should retrieve an empty list if there is no objects in the store', () async {
    final objects = await db.getAll(store: fakeRawStore);
    expect(objects.isEmpty, true);
  });

  test('DatabaseRepositoryImpl should emit new events when listening to store updates', () async {
    final stream = await db.listenAll(store: fakeRawStore);

    final expectedEmissions = <List<Map<String, String>>>[
      [], // First emission is the "onListen", which is an empty store
      [fakeObject],
      List.generate(2, (_) => fakeObject),
    ];

    expect(stream, emitsInOrder(expectedEmissions));

    await fakeRecord.put(memorySembast, fakeObject);
    await stringMapStoreFactory.store(fakeRawStore).record('other-fake-id').put(memorySembast, fakeObject);
  });
}
