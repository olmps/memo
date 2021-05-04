import 'package:memo/data/repositories/user_repository.dart';

/// Handles all domain-specific operations pertaining a `User`
abstract class UserServices {
  /// If there is no existing `User`, creates one
  Future<void> createUserIfNeeded();
}

class UserServicesImpl implements UserServices {
  UserServicesImpl(this.userRepo);

  final UserRepository userRepo;

  @override
  Future<void> createUserIfNeeded() async {
    final currentUser = await userRepo.getUser();

    if (currentUser == null) {
      await userRepo.createUser();
    }
  }
}
