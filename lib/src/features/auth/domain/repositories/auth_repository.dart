import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({
    required String identifier,
    required String password,
  });

  Future<AuthSession> refreshSession();

  Future<AuthSession> selectActiveRole(String activeRole);

  Future<void> clearLocalSession();

  Future<void> logout();
}
