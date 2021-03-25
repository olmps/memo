import 'package:equatable/equatable.dart';

/// Handles the local persistence to a database
///
/// To store primitives values, use `StorageRepository`.
abstract class DatabaseRepository {
  /// Adds an [object] to the [store], using a [serializer]
  ///
  /// If there is already an object with the same [KeyStorable.id], the default behavior should be merging all of its
  /// fields
  Future<void> put<T extends KeyStorable>({
    required T object,
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
  });

  /// Deletes the value with [key] from the [store]
  Future<void> removeObject<T extends KeyStorable>({required String key, required DatabaseStore store});

  /// Retrieves an object with [key] from the [store]
  ///
  /// Returns `null` if the key doesn't exist
  Future<T?> getObject<T extends KeyStorable>({
    required String key,
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
  });

  /// Retrieves all objects within [store]
  Future<List<T>> getAll<T extends KeyStorable>({
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
  });

  /// Retrieves a stream of all the [store] objects, triggered whenever any update occurs to this [store]
  Future<Stream<List<T>>> listenAll<T extends KeyStorable>({
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
  });
}

enum DatabaseStore {
  decks,
  cards,
  executions,
  resources,
}

/// Middleware that should be responsible of parsing a type [T] to/from a JSON representation
abstract class JsonSerializer<T extends Object> {
  T fromMap(Map<String, dynamic> json);
  Map<String, dynamic> mapOf(T object);
}

/// Base class that adds a key [id] to allow its implementation to be stored/identified in any database
abstract class KeyStorable extends Equatable {
  const KeyStorable({required this.id});
  final String id;
}
