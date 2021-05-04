import 'dart:async';

import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/user_serializer.dart';
import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/user.dart';

/// Handles all read, write and serialization operations pertaining to a [User]
abstract class UserRepository {
  /// Retrieves the current [User] and keeps listening to any changes made to it
  Future<Stream<User>> listenToUser();

  /// Retrieves the current [User]
  Future<User?> getUser();

  /// Creates a new pristine [User]
  Future<void> createUser();

  /// Updates the [User] with the execution-related arguments
  ///
  /// Any update made to these properties, will override the current value, so make sure to update with the latest
  /// corresponding values.
  Future<void> updateExecution({required Map<MemoDifficulty, int> executionsAmounts, required int timeSpentInMillis});
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._db);

  final SembastDatabase _db;
  final _mainStore = '';
  final _userRecord = 'user';

  final _userSerializer = UserSerializer();

  @override
  Future<Stream<User>> listenToUser() async {
    final rawUser = await _db.listenTo(id: _userRecord, store: _mainStore);
    return rawUser.map((user) {
      if (user == null) {
        throw InconsistentStateError.repository('Missing required user');
      }

      return _userSerializer.from(user);
    });
  }

  @override
  Future<User?> getUser() async {
    final rawUser = await _db.get(id: _userRecord, store: _mainStore);
    return rawUser != null ? _userSerializer.from(rawUser) : null;
  }

  @override
  Future<void> createUser() async {
    const executionsGoal = 10;
    final encodedUser = _userSerializer.to(User(memosExecutionChunkGoal: executionsGoal));
    await _db.put(id: _userRecord, object: encodedUser, store: _mainStore);
  }

  @override
  Future<void> updateExecution({required Map<MemoDifficulty, int> executionsAmounts, required int timeSpentInMillis}) =>
      _db.put(
        id: _userRecord,
        object: <String, dynamic>{
          UserKeys.executionsAmounts: executionsAmounts.map((key, value) => MapEntry(key.raw, value)),
          UserKeys.timeSpentInMillis: timeSpentInMillis,
        },
        store: _mainStore,
      );
}
