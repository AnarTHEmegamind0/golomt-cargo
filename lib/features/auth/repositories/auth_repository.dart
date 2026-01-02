import 'package:core/features/auth/models/user.dart';

abstract interface class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<void> logout();
}

