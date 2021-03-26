import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/database_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

class MockSerializer extends Mock implements JsonSerializer<MockSerializable> {}

// ignore: avoid_implementing_value_types
class MockSerializable extends Mock implements KeyStorable {}

void main() {
  final serializer = MockSerializer();
  final serializable = MockSerializable();

  final fakeRawSerializable = {'fake': 'fake'};
  const fakeSerializableId = 'a-fake-id';
  const fakeStore = DatabaseStore.cards;
  final fakeRecord = stringMapStoreFactory.store(fakeStore.key).record(fakeSerializableId);

  late Database memorySembast;
  late DatabaseRepository db;

  setUpAll(() {
    registerFallbackValue<MockSerializable>(MockSerializable());
  });

  setUp(() async {
    await databaseFactoryMemory.deleteDatabase('test.db');
    memorySembast = await databaseFactoryMemory.openDatabase('test.db');
    db = DatabaseRepositoryImpl(memorySembast);

    reset(serializer);
    reset(serializable);

    when(() => serializer.mapOf(any())).thenReturn(fakeRawSerializable);
    when(() => serializer.fromMap(any())).thenReturn(serializable);
    when(() => serializable.id).thenReturn(fakeSerializableId);
  });

  test('DatabaseRepositoryImpl should put a new object', () async {
    expect(await fakeRecord.get(memorySembast), null);

    await db.put<MockSerializable>(object: serializable, serializer: serializer, store: fakeStore);

    expect(await fakeRecord.get(memorySembast), fakeRawSerializable);
    verify(() => serializer.mapOf(serializable)).called(1);
  });

  test('DatabaseRepositoryImpl should update an existing object', () async {
    await fakeRecord.put(memorySembast, fakeRawSerializable);

    final fakeUpdatedRawSerializable = {'fake': 'fakeUpdated', 'newFake': 'fake'};
    when(() => serializer.mapOf(any())).thenReturn(fakeUpdatedRawSerializable);

    await db.put<MockSerializable>(object: serializable, serializer: serializer, store: fakeStore);

    expect(await fakeRecord.get(memorySembast), fakeUpdatedRawSerializable);
    verify(() => serializer.mapOf(serializable)).called(1);
  });

  test('DatabaseRepositoryImpl should remove pre-existing fields in an update without merge', () async {
    await fakeRecord.put(memorySembast, fakeRawSerializable);

    final fakeUpdatedRawSerializable = {'newFake': 'fake'};
    when(() => serializer.mapOf(any())).thenReturn(fakeUpdatedRawSerializable);

    await db.put<MockSerializable>(object: serializable, serializer: serializer, store: fakeStore, shouldMerge: false);

    expect(await fakeRecord.get(memorySembast), fakeUpdatedRawSerializable);
    verify(() => serializer.mapOf(serializable)).called(1);
  });

  test('DatabaseRepositoryImpl should maintain pre-existing fields in an update with merge', () async {
    await fakeRecord.put(memorySembast, fakeRawSerializable);

    final fakeUpdatedRawSerializable = {'newFake': 'fake'};
    when(() => serializer.mapOf(any())).thenReturn(fakeUpdatedRawSerializable);

    await db.put<MockSerializable>(object: serializable, serializer: serializer, store: fakeStore);

    fakeUpdatedRawSerializable.addAll(fakeRawSerializable);
    expect(await fakeRecord.get(memorySembast), fakeUpdatedRawSerializable);
    verify(() => serializer.mapOf(serializable)).called(1);
  });

  test('DatabaseRepositoryImpl should remove an existing object', () async {
    await fakeRecord.put(memorySembast, fakeRawSerializable);

    expect(await fakeRecord.get(memorySembast), fakeRawSerializable);
    await db.removeObject(key: fakeSerializableId, store: fakeStore);
    expect(await fakeRecord.get(memorySembast), null);
  });

  test('DatabaseRepositoryImpl should do nothing when removing a nonexistent object', () async {
    await fakeRecord.put(memorySembast, fakeRawSerializable);

    await db.removeObject(key: fakeSerializableId, store: fakeStore);
    expect(await fakeRecord.get(memorySembast), null);
  });

  test('DatabaseRepositoryImpl should retrieve a single existing object', () async {
    await fakeRecord.put(memorySembast, fakeRawSerializable);

    final object = await db.getObject<MockSerializable>(
      key: fakeSerializableId,
      serializer: serializer,
      store: fakeStore,
    );
    expect(object, isNotNull);
  });

  test('DatabaseRepositoryImpl should get null when retrieving a single nonexistent object', () async {
    final object = await db.getObject<MockSerializable>(
      key: fakeSerializableId,
      serializer: serializer,
      store: fakeStore,
    );
    expect(object, null);
  });

  test('DatabaseRepositoryImpl should retrieve multiple objects', () async {
    await fakeRecord.put(memorySembast, fakeRawSerializable);
    await stringMapStoreFactory.store(fakeStore.key).record('2').put(memorySembast, fakeRawSerializable);

    final objects = await db.getAll<MockSerializable>(serializer: serializer, store: fakeStore);
    expect(objects.length, 2);
  });

  test('DatabaseRepositoryImpl should retrieve an empty list if there is no objects in the store', () async {
    final objects = await db.getAll<MockSerializable>(serializer: serializer, store: fakeStore);
    expect(objects.isEmpty, true);
  });

  // TODO(matuella): Find a way to test the listenAll
}
