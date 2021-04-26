import 'dart:async';

import 'package:memo/data/repositories/user_repository.dart';
import 'package:memo/domain/models/memo_execution.dart';

/// Handles all domain-specific operations pertaining to the user's progress
abstract class ProgressServices {
  /// Retrieves the [MemoExecutionsMetadata] for this `User` and keeps listening to any changes made to them
  Future<Stream<MemoExecutionsMetadata>> listenToUserProgress();
}

class ProgressServicesImpl implements ProgressServices {
  ProgressServicesImpl({required this.userRepo});

  final UserRepository userRepo;

  @override
  Future<Stream<MemoExecutionsMetadata>> listenToUserProgress() => userRepo.listenToUser();
}
