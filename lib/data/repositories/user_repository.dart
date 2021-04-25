import 'dart:async';

import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/user_serializer.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/user.dart';

/// Handles all domain-specific operations pertaining to a [User]
abstract class UserRepository {
  /// Retrieves the current [User] and keeps listening to any changes made to it
  Future<Stream<User>> listenToUser();

  /// Retrieves the current [User]
  Future<User> getUser();

  /// Updates the [User] with the execution-related arguments
  ///
  /// Any update made to these properties, will override the current value, so make sure to update with the latest
  /// corresponding values.
  Future<void> updateExecution({required Map<MemoDifficulty, int> executionsAmounts, required int timeSpentInMillis});
}

final _userSerializer = UserSerializer();
final _userStreamTransformer = StreamTransformer<Map<String, Object>, User>.fromHandlers(handleData: (rawUser, sink) {
  sink.add(_userSerializer.from(rawUser));
});

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._db);

  final SembastDatabase _db;
  final _mainStore = '';
  final _userRecord = 'user';

  @override
  Future<Stream<User>> listenToUser() async {
    final rawUser = await _db.listenTo(id: _userRecord, store: _mainStore);
    return rawUser.transform(_userStreamTransformer);
  }

  @override
  Future<User> getUser() async {
    final rawUser = await _db.get(id: _userRecord, store: _mainStore);
    if (rawUser == null) {
      throw InconsistentStateError.repository('Missing required user (of record "$_userRecord") in main store');
    }

    return _userSerializer.from(rawUser);
  }

  @override
  Future<void> updateExecution({required Map<MemoDifficulty, int> executionsAmounts, required int timeSpentInMillis}) =>
      _db.put(
        id: _userRecord,
        object: <String, dynamic>{
          UserKeys.executionsAmounts: executionsAmounts,
          UserKeys.timeSpentInMillis: timeSpentInMillis,
        },
        store: _mainStore,
      );
}
