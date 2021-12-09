import 'package:flutter_test/flutter_test.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
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

  test('SembastDatabaseImpl should put a new object', () async {
    expect(await fakeRecord.get(memorySembast), isNull);

    await db.put(id: fakeRecordId, object: fakeObject, store: fakeRawStore);

    expect(await fakeRecord.get(memorySembast), fakeObject);
  });

  test('SembastDatabaseImpl should put multiple objects at once', () async {
    expect(await fakeRecord.get(memorySembast), isNull);

    final records = [fakeRecordId, 'second-$fakeRecordId'];
    final fakeObjects = [fakeObject, fakeObject];
    await db.putAll(ids: records, objects: fakeObjects, store: fakeRawStore);

    expect(await fakeStore.records(records).get(memorySembast), fakeObjects);
  });

  test('SembastDatabaseImpl should update an existing object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final fakeUpdatedObject = {'fake': 'fakeUpdated', 'newFake': 'fake'};

    await db.put(id: fakeRecordId, object: fakeUpdatedObject, store: fakeRawStore);

    expect(await fakeRecord.get(memorySembast), fakeUpdatedObject);
  });

  test('SembastDatabaseImpl should remove pre-existing fields in an update without merge', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final fakeUpdatedObject = {'newFake': 'fake'};

    await db.put(id: fakeRecordId, object: fakeUpdatedObject, store: fakeRawStore, shouldMerge: false);

    expect(await fakeRecord.get(memorySembast), fakeUpdatedObject);
  });

  test('SembastDatabaseImpl should maintain pre-existing fields in an update with merge', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final fakeUpdatedObject = {'newFake': 'fake'};

    await db.put(id: fakeRecordId, object: fakeUpdatedObject, store: fakeRawStore);

    fakeUpdatedObject.addAll(fakeObject);
    expect(await fakeRecord.get(memorySembast), fakeUpdatedObject);
  });

  test('SembastDatabaseImpl should remove an existing object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    expect(await fakeRecord.get(memorySembast), fakeObject);
    await db.remove(id: fakeRecordId, store: fakeRawStore);
    expect(await fakeRecord.get(memorySembast), isNull);

    expect(await fakeRecord.get(memorySembast), isNull);
  });

  test('SembastDatabaseImpl should remove multiple existing objects at once', () async {
    final records = [fakeRecordId, 'second-$fakeRecordId'];
    final fakeObjects = [fakeObject, fakeObject];
    await fakeStore.records(records).put(memorySembast, fakeObjects);

    expect(await fakeStore.records(records).get(memorySembast), fakeObjects);
    await db.removeAll(ids: records, store: fakeRawStore);

    expect(await fakeStore.find(memorySembast), const <dynamic>[]);
  });

  test('SembastDatabaseImpl should do nothing when removing a nonexistent object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    await db.remove(id: fakeRecordId, store: fakeRawStore);
    expect(await fakeRecord.get(memorySembast), isNull);
  });

  test('SembastDatabaseImpl should retrieve a single existing object', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    final object = await db.get(id: fakeRecordId, store: fakeRawStore);
    expect(object, isNotNull);
  });

  test('SembastDatabaseImpl should retrieve multiple existing objects by their ids', () async {
    final records = [fakeRecordId, 'second-$fakeRecordId'];
    final fakeObjects = [fakeObject, fakeObject];
    await fakeStore.records(records).put(memorySembast, fakeObjects);

    final objects = await db.getAllByIds(ids: records, store: fakeRawStore);
    expect(objects, fakeObjects);
  });

  test('SembastDatabaseImpl should get null when retrieving a single nonexistent object', () async {
    final object = await db.get(id: fakeRecordId, store: fakeRawStore);
    expect(object, isNull);
  });

  test('SembastDatabaseImpl should retrieve multiple objects', () async {
    await fakeRecord.put(memorySembast, fakeObject);
    await stringMapStoreFactory.store(fakeRawStore).record('2').put(memorySembast, fakeObject);

    final objects = await db.getAll(store: fakeRawStore);
    expect(objects.length, 2);
  });

  test('SembastDatabaseImpl should retrieve an empty list if there is no objects in the store', () async {
    final objects = await db.getAll(store: fakeRawStore);
    expect(objects.isEmpty, true);
  });

  test('SembastDatabaseImpl should emit new events when listening to store updates', () async {
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

  test('SembastTransactionHandler should not make any updates in a failed transaction', () async {
    await fakeRecord.put(memorySembast, fakeObject);

    try {
      await db.runInTransaction(() async {
        const generatedRecords = 10;
        final fakeRecordsIds = List.generate(generatedRecords, (index) => '$fakeRecordId-$index');
        await db.putAll(
          ids: fakeRecordsIds,
          objects: fakeRecordsIds.map((_) => fakeObject).toList(),
          store: fakeRawStore,
        );
        final updatedAddedRecords = await db.getAll(store: fakeRawStore);
        expect(updatedAddedRecords.length, generatedRecords + 1);

        await db.remove(id: fakeRecordId, store: fakeRawStore);
        final updatedRemovedRecord = await db.getAll(store: fakeRawStore);
        expect(updatedRemovedRecord.length, generatedRecords);

        throw Error();
      });
      // ignore: avoid_catches_without_on_clauses, empty_catches
    } catch (error) {}

    final records = await db.getAll(store: fakeRawStore);
    expect(records.length, 1);
  });

  test('SembastTransactionHandler should correctly store multiple updates in a transaction', () async {
    const secondRecordId = 'second-$fakeRecordId';
    await Future.wait([
      fakeRecord.put(memorySembast, fakeObject),
      fakeStore.record(secondRecordId).put(memorySembast, fakeObject),
    ]);

    await db.runInTransaction(() async {
      await db.remove(id: fakeRecordId, store: fakeRawStore);
      await db.remove(id: secondRecordId, store: fakeRawStore);
    });

    expect(await db.getAll(store: fakeRawStore), isEmpty);
  });

  test('SembastTransactionHandler should throw an error if multiple transactions are created simultaneously', () async {
    await expectLater(
      () async {
        await Future.wait([
          db.runInTransaction(() async {
            await Future.delayed(const Duration(seconds: 1), () {});
          }),
          db.runInTransaction(() async {
            await Future.delayed(const Duration(seconds: 1), () {});
          }),
        ]);
      },
      throwsA(isA<InconsistentStateError>()),
    );
  });
}
