import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_session.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/active_role_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/refresh_token_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDatasource, this._sessionStorage);

  final AuthRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  @override
  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _remoteDatasource.login(
      LoginRequest(
        identifier: identifier,
        password: password,
      ),
    );

    return _persist(response);
  }

  @override
  Future<AuthSession> refreshSession() async {
    final refreshToken = await _sessionStorage.readRefreshToken();
    if (refreshToken == null) {
      throw const ApiException(
        code: 'AUTH_SESSION_MISSING',
        message: 'Phiên đăng nhập không tồn tại',
      );
    }

    final response = await _remoteDatasource.refreshToken(
      RefreshTokenRequest(refreshToken),
    );
    return _persist(response);
  }

  @override
  Future<AuthSession> selectActiveRole(String activeRole) async {
    final accessToken = await _sessionStorage.readAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        code: 'AUTH_SESSION_MISSING',
        message: 'Phiên đăng nhập không tồn tại',
      );
    }

    final response = await _remoteDatasource.selectActiveRole(
      request: ActiveRoleRequest(activeRole),
      accessToken: accessToken,
    );
    return _persist(response);
  }

  @override
  Future<void> logout() async {
    final accessToken = await _sessionStorage.readAccessToken();
    try {
      if (accessToken != null) {
        await _remoteDatasource.logout(accessToken);
      }
    } finally {
      await _sessionStorage.clear();
    }
  }

  Future<AuthSession> _persist(LoginResponse response) async {
    await _sessionStorage.save(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    return response.toEntity();
  }
}
