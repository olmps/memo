import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_executions_metadata.dart';
import 'package:meta/meta.dart';

/// Groups all non-auth-related properties about an [User].
///
/// Through [MemoExecutionsMetadata], this class also includes properties that describes all user-wide `Memo`s
/// executions.
@immutable
class User extends MemoExecutionsMetadata {
  User({
    required this.id,
    required this.executionChunk,
    Map<MemoDifficulty, int> executionsDifficulty = const {},
    int timeSpentInMillis = 0,
  }) : super(timeSpentInMillis, executionsDifficulty);

  /// Unique [id] for this user.
  ///
  /// This is the same as [UserAuth.id].
  final String id;

  /// Amount of `Memo`s expected to be executed per execution-event.
  final int executionChunk;

  @override
  List<Object?> get props => [executionChunk, ...super.props];
}

/// Groups all auth-related properties about an [User].
class UserAuth extends Equatable {
  const UserAuth({required this.id, required this.token});

  /// Unique [id] for this user.
  ///
  /// This is the same as [User.id].
  final String id;
  final String token;

  @override
  List<Object?> get props => [id, token];
}
