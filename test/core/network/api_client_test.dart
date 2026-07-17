import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myfschoolse1913/src/core/network/api_client.dart';
import 'package:myfschoolse1913/src/core/network/api_exception.dart';

void main() {
  test('authenticated 401 triggers session expiry callback', () async {
    var callbackCount = 0;
    final apiClient = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer expired-token');
        return _errorResponse(
          statusCode: 401,
          code: 'UNAUTHORIZED',
          message: 'Bạn cần đăng nhập để truy cập chức năng này',
        );
      }),
      onUnauthorized: () async {
        callbackCount++;
      },
    );
    addTearDown(apiClient.close);

    await expectLater(
      apiClient.get('/learning-results', accessToken: 'expired-token'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 401)
            .having((error) => error.code, 'code', 'UNAUTHORIZED'),
      ),
    );

    expect(callbackCount, 1);
  });

  test('authenticated 401 refreshes and retries with the new token', () async {
    var requestCount = 0;
    var refreshCount = 0;
    var unauthorizedCount = 0;
    final apiClient = ApiClient(
      httpClient: MockClient((request) async {
        requestCount++;
        if (requestCount == 1) {
          expect(request.headers['Authorization'], 'Bearer expired-token');
          return _errorResponse(
            statusCode: 401,
            code: 'UNAUTHORIZED',
            message: 'Access token đã hết hạn',
          );
        }

        expect(request.headers['Authorization'], 'Bearer refreshed-token');
        return _successResponse(const <String, Object?>{'value': 'loaded'});
      }),
      onRefreshAccessToken: () async {
        refreshCount++;
        return 'refreshed-token';
      },
      onUnauthorized: () async {
        unauthorizedCount++;
      },
    );
    addTearDown(apiClient.close);

    final result = await apiClient.get(
      '/learning-results',
      accessToken: 'expired-token',
    );

    expect(result, const <String, Object?>{'value': 'loaded'});
    expect(requestCount, 2);
    expect(refreshCount, 1);
    expect(unauthorizedCount, 0);
  });

  test('unauthenticated login 401 does not trigger session expiry', () async {
    var callbackCount = 0;
    final apiClient = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.headers['Authorization'], isNull);
        return _errorResponse(
          statusCode: 401,
          code: 'AUTH_INVALID_CREDENTIALS',
          message: 'Thông tin đăng nhập không đúng',
        );
      }),
      onUnauthorized: () async {
        callbackCount++;
      },
    );
    addTearDown(apiClient.close);

    await expectLater(
      apiClient.post(
        '/auth/login',
        body: const <String, Object?>{
          'identifier': 'parent01',
          'password': 'wrong-password',
        },
      ),
      throwsA(
        isA<ApiException>().having(
          (error) => error.code,
          'code',
          'AUTH_INVALID_CREDENTIALS',
        ),
      ),
    );

    expect(callbackCount, 0);
  });

  test('authenticated 403 does not trigger session expiry', () async {
    var callbackCount = 0;
    final apiClient = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer active-token');
        return _errorResponse(
          statusCode: 403,
          code: 'FORBIDDEN',
          message: 'Bạn không có quyền thực hiện thao tác này',
        );
      }),
      onUnauthorized: () async {
        callbackCount++;
      },
    );
    addTearDown(apiClient.close);

    await expectLater(
      apiClient.get('/teacher/resource', accessToken: 'active-token'),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 403)
            .having((error) => error.code, 'code', 'FORBIDDEN'),
      ),
    );

    expect(callbackCount, 0);
  });
}

http.Response _errorResponse({
  required int statusCode,
  required String code,
  required String message,
}) {
  return http.Response(
    jsonEncode(<String, Object?>{
      'success': false,
      'data': null,
      'error': <String, Object?>{
        'code': code,
        'message': message,
        'details': null,
      },
    }),
    statusCode,
    headers: const <String, String>{
      'content-type': 'application/json; charset=utf-8',
    },
  );
}

http.Response _successResponse(Object? data) {
  return http.Response(
    jsonEncode(<String, Object?>{'success': true, 'data': data, 'error': null}),
    200,
    headers: const <String, String>{
      'content-type': 'application/json; charset=utf-8',
    },
  );
}
