import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

enum LoginStatus { idle, loading, success, error, sessionExpired }

class LoginController extends ChangeNotifier {
  LoginController(this._authRepository);

  final AuthRepository _authRepository;

  LoginStatus _status = LoginStatus.idle;
  AuthSession? _session;
  String? _errorMessage;
  int _sessionVersion = 0;

  LoginStatus get status => _status;
  AuthSession? get session => _session;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == LoginStatus.loading;

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    if (isLoading) {
      return;
    }

    _sessionVersion++;
    final operationVersion = _sessionVersion;

    _setState(status: LoginStatus.loading, session: null, errorMessage: null);

    try {
      final session = await _authRepository.login(
        identifier: identifier.trim(),
        password: password,
      );

      if (operationVersion != _sessionVersion) {
        await _authRepository.clearLocalSession();
        return;
      }

      _setState(
        status: LoginStatus.success,
        session: session,
        errorMessage: null,
      );
    } on ApiException catch (error) {
      if (operationVersion != _sessionVersion) {
        return;
      }
      _setState(
        status: LoginStatus.error,
        session: null,
        errorMessage: _mapApiError(error),
      );
    } catch (_) {
      if (operationVersion != _sessionVersion) {
        return;
      }
      _setState(
        status: LoginStatus.error,
        session: null,
        errorMessage: 'Đã xảy ra lỗi. Vui lòng thử lại.',
      );
    }
  }

  Future<void> selectActiveRole(String activeRole) async {
    if (isLoading) {
      return;
    }

    final operationVersion = _sessionVersion;

    _setState(
      status: LoginStatus.loading,
      session: _session,
      errorMessage: null,
    );

    try {
      final session = await _authRepository.selectActiveRole(activeRole);
      if (operationVersion != _sessionVersion) {
        await _authRepository.clearLocalSession();
        return;
      }
      _setState(
        status: LoginStatus.success,
        session: session,
        errorMessage: null,
      );
    } on ApiException catch (error) {
      if (operationVersion != _sessionVersion) {
        return;
      }
      _setState(
        status: LoginStatus.error,
        session: _session,
        errorMessage: _mapApiError(error),
      );
    } catch (_) {
      if (operationVersion != _sessionVersion) {
        return;
      }
      _setState(
        status: LoginStatus.error,
        session: _session,
        errorMessage: 'Đã xảy ra lỗi. Vui lòng thử lại.',
      );
    }
  }

  Future<void> logout() async {
    if (isLoading) {
      return;
    }

    _sessionVersion++;

    _setState(
      status: LoginStatus.loading,
      session: _session,
      errorMessage: null,
    );

    try {
      await _authRepository.logout();
    } finally {
      _setState(status: LoginStatus.idle, session: null, errorMessage: null);
    }
  }

  Future<void> expireSession() {
    return _expireSession(
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
    );
  }

  Future<void> expireInactiveSession() {
    return _expireSession(
      'Phiên đăng nhập đã kết thúc do không hoạt động trong 30 phút.',
    );
  }

  Future<void> _expireSession(String message) async {
    if (_status == LoginStatus.sessionExpired) {
      return;
    }

    _sessionVersion++;
    try {
      await _authRepository.clearLocalSession();
    } finally {
      _setState(
        status: LoginStatus.sessionExpired,
        session: null,
        errorMessage: message,
      );
    }
  }

  Future<String?> refreshAccessToken() async {
    final operationVersion = _sessionVersion;
    try {
      final refreshedSession = await _authRepository.refreshSession();
      if (operationVersion != _sessionVersion ||
          _status == LoginStatus.sessionExpired) {
        await _authRepository.clearLocalSession();
        return null;
      }
      _setState(
        status: LoginStatus.success,
        session: refreshedSession,
        errorMessage: null,
      );
      return refreshedSession.accessToken;
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    if (_status != LoginStatus.error) {
      return;
    }

    _setState(status: LoginStatus.idle, session: null, errorMessage: null);
  }

  String _mapApiError(ApiException error) {
    return switch (error.code) {
      'AUTH_INVALID_CREDENTIALS' =>
        'Số điện thoại, tên đăng nhập hoặc mật khẩu không đúng.',
      'AUTH_ACCOUNT_LOCKED' =>
        'Tài khoản đã bị khóa. Vui lòng liên hệ nhà trường.',
      'AUTH_ROLE_NOT_AVAILABLE' =>
        'Vai trò đã chọn không còn khả dụng. Vui lòng đăng nhập lại.',
      'NETWORK_TIMEOUT' => 'Kết nối quá thời gian. Vui lòng thử lại.',
      'NETWORK_ERROR' =>
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      _ => error.message,
    };
  }

  void _setState({
    required LoginStatus status,
    required AuthSession? session,
    required String? errorMessage,
  }) {
    _status = status;
    _session = session;
    _errorMessage = errorMessage;
    notifyListeners();
  }
}
