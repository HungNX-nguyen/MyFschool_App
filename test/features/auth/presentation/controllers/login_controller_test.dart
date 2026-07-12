import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/core/network/api_exception.dart';
import 'package:myfschoolse1913/src/features/auth/domain/entities/account.dart';
import 'package:myfschoolse1913/src/features/auth/domain/entities/auth_session.dart';
import 'package:myfschoolse1913/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:myfschoolse1913/src/features/auth/presentation/controllers/login_controller.dart';

void main() {
  const session = AuthSession(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'Bearer',
    expiresIn: 3600,
    account: Account(
      id: 1,
      username: 'parent01',
      roles: <String>['PARENT'],
      activeRole: 'PARENT',
      status: 'ACTIVE',
      fullName: 'Nguyen Van Parent',
    ),
  );

  test('changes status to success when login succeeds', () async {
    final repository = _FakeAuthRepository(result: session);
    final controller = LoginController(repository);

    await controller.login(
      identifier: ' parent01 ',
      password: 'password123',
    );

    expect(controller.status, LoginStatus.success);
    expect(controller.session, same(session));
    expect(controller.errorMessage, isNull);
    expect(repository.lastIdentifier, 'parent01');
  });

  test('maps invalid credentials to a user-friendly error', () async {
    final repository = _FakeAuthRepository(
      error: const ApiException(
        code: 'AUTH_INVALID_CREDENTIALS',
        message: 'Invalid credentials',
        statusCode: 401,
      ),
    );
    final controller = LoginController(repository);

    await controller.login(
      identifier: 'parent01',
      password: 'wrong-password',
    );

    expect(controller.status, LoginStatus.error);
    expect(controller.session, isNull);
    expect(controller.errorMessage, contains('không đúng'));
  });

  test('ignores a second submit while login is loading', () async {
    final completer = Completer<AuthSession>();
    final repository = _FakeAuthRepository(completer: completer);
    final controller = LoginController(repository);

    final firstLogin = controller.login(
      identifier: 'parent01',
      password: 'password123',
    );
    await controller.login(
      identifier: 'parent01',
      password: 'password123',
    );

    expect(repository.callCount, 1);
    expect(controller.status, LoginStatus.loading);

    completer.complete(session);
    await firstLogin;

    expect(controller.status, LoginStatus.success);
  });

  test('updates the session after selecting an active role', () async {
    const selectedSession = AuthSession(
      accessToken: 'new-access-token',
      refreshToken: 'new-refresh-token',
      tokenType: 'Bearer',
      expiresIn: 3600,
      account: Account(
        id: 1,
        username: 'parent01',
        roles: <String>['PARENT', 'TEACHER'],
        activeRole: 'TEACHER',
        status: 'ACTIVE',
      ),
    );
    final repository = _FakeAuthRepository(roleResult: selectedSession);
    final controller = LoginController(repository);

    await controller.selectActiveRole('TEACHER');

    expect(repository.lastSelectedRole, 'TEACHER');
    expect(controller.status, LoginStatus.success);
    expect(controller.session, same(selectedSession));
  });

  test('clears the session after logout', () async {
    final repository = _FakeAuthRepository(result: session);
    final controller = LoginController(repository);

    await controller.login(
      identifier: 'parent01',
      password: 'password123',
    );
    await controller.logout();

    expect(repository.logoutCalled, isTrue);
    expect(controller.status, LoginStatus.idle);
    expect(controller.session, isNull);
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.result,
    this.error,
    this.completer,
    this.roleResult,
  });

  final AuthSession? result;
  final Object? error;
  final Completer<AuthSession>? completer;
  final AuthSession? roleResult;

  int callCount = 0;
  String? lastIdentifier;
  String? lastSelectedRole;
  bool logoutCalled = false;

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<AuthSession> refreshSession() {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> selectActiveRole(String activeRole) async {
    lastSelectedRole = activeRole;
    return roleResult!;
  }

  @override
  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    callCount++;
    lastIdentifier = identifier;

    if (error != null) {
      throw error!;
    }
    if (completer != null) {
      return completer!.future;
    }
    return result!;
  }
}
