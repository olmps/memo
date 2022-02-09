import 'package:memo/data/repositories/user_repository.dart';
import 'package:memo/domain/models/memo_executions_metadata.dart';

abstract class ListenToUserExecutionsUC {
  Stream<MemoExecutionsMetadata> run();
}

class ListenToUserExecutionsUCImpl implements ListenToUserExecutionsUC {
  ListenToUserExecutionsUCImpl(this.userRepo);
  final UserRepository userRepo;

  @override
  Stream<MemoExecutionsMetadata> run() => userRepo.listenToUserInfo();
}
