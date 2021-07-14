import 'package:memo/data/repositories/user_repository.dart';

/// Handles all domain-specific operations associated with an `User`.
abstract class UserServices {
  /// Creates a new `User` if there is no existing one.
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
