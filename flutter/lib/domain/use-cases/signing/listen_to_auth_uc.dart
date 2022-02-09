import 'package:memo/data/repositories/auth_repository.dart';
import 'package:memo/domain/models/user.dart';

abstract class ListenToAuthUC {
  Stream<UserAuth?> run();
}

// TODO(matuella): does this use-case make sense? It doesn't seem like an "action", more like a side-effect
class ListenToAuthUCImpl implements ListenToAuthUC {
  ListenToAuthUCImpl(this.authRepo);

  final AuthRepository authRepo;

  @override
  Stream<UserAuth?> run() => authRepo.listenToAuth(); // TODO(matuella): Error handling
}
