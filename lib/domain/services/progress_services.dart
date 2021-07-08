import 'dart:async';

import 'package:memo/data/repositories/user_repository.dart';
import 'package:memo/domain/models/memo_execution.dart';

/// Handles all domain-specific operations associated with the user's progress.
abstract class ProgressServices {
  /// Streams the current `User`, which emits a new event when any change occurs.
  Future<Stream<MemoExecutionsMetadata>> listenToUserProgress();
}

class ProgressServicesImpl implements ProgressServices {
  ProgressServicesImpl({required this.userRepo});

  final UserRepository userRepo;

  @override
  Future<Stream<MemoExecutionsMetadata>> listenToUserProgress() => userRepo.listenToUser();
}
