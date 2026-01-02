import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<User> login({required String email, required String password}) async {
    return User(id: 'user_1', email: email);
  }

  @override
  Future<void> logout() async {}
}

