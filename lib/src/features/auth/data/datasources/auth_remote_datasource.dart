import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/active_role_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/refresh_token_request.dart';

class AuthRemoteDatasource {
  const AuthRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<LoginResponse> login(LoginRequest request) async {
    final data = await _apiClient.post('/auth/login', body: request.toJson());
    return _parseAuthResponse(data);
  }

  Future<LoginResponse> refreshToken(RefreshTokenRequest request) async {
    final data = await _apiClient.post(
      '/auth/refresh-token',
      body: request.toJson(),
    );
    return _parseAuthResponse(data);
  }

  Future<LoginResponse> selectActiveRole({
    required ActiveRoleRequest request,
    required String accessToken,
  }) async {
    final data = await _apiClient.post(
      '/auth/active-role',
      body: request.toJson(),
      accessToken: accessToken,
    );
    return _parseAuthResponse(data);
  }

  Future<void> logout(String accessToken) async {
    await _apiClient.post('/auth/logout', accessToken: accessToken);
  }

  LoginResponse _parseAuthResponse(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu xác thực từ máy chủ không hợp lệ',
      );
    }
    return LoginResponse.fromJson(data);
  }
}
