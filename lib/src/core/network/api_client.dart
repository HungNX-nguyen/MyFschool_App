import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 15),
    this.onRefreshAccessToken,
    this.onUnauthorized,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final Duration timeout;
  Future<String?> Function()? onRefreshAccessToken;
  Future<void> Function()? onUnauthorized;

  Future<String?>? _refreshAccessTokenFuture;
  bool _isHandlingUnauthorized = false;

  Future<Object?> get(String path, {String? accessToken}) {
    return _send(
      (requestAccessToken) => _httpClient.get(
        AppConfig.apiUri(path),
        headers: _headers(requestAccessToken),
      ),
      accessToken: accessToken,
    );
  }

  Future<Object?> post(
    String path, {
    Map<String, Object?>? body,
    String? accessToken,
  }) {
    return _send(
      (requestAccessToken) => _httpClient.post(
        AppConfig.apiUri(path),
        headers: _headers(requestAccessToken),
        body: jsonEncode(body ?? const <String, Object?>{}),
      ),
      accessToken: accessToken,
    );
  }

  Future<Object?> patch(
    String path, {
    Map<String, Object?>? body,
    String? accessToken,
  }) {
    return _send(
      (requestAccessToken) => _httpClient.patch(
        AppConfig.apiUri(path),
        headers: _headers(requestAccessToken),
        body: jsonEncode(body ?? const <String, Object?>{}),
      ),
      accessToken: accessToken,
    );
  }

  Future<Object?> _send(
    Future<http.Response> Function(String? accessToken) request, {
    required String? accessToken,
  }) async {
    try {
      final response = await request(accessToken).timeout(timeout);

      try {
        return _parseResponse(response);
      } on ApiException catch (error) {
        if (accessToken == null || error.statusCode != 401) {
          rethrow;
        }

        final refreshedAccessToken = await _refreshAccessToken();
        if (refreshedAccessToken == null) {
          await _handleUnauthorized();
          rethrow;
        }

        final retryResponse = await request(
          refreshedAccessToken,
        ).timeout(timeout);
        try {
          return _parseResponse(retryResponse);
        } on ApiException catch (retryError) {
          if (retryError.statusCode == 401) {
            await _handleUnauthorized();
          }
          rethrow;
        }
      }
    } on TimeoutException {
      throw const ApiException(
        code: 'NETWORK_TIMEOUT',
        message: 'Kết nối đến máy chủ quá thời gian',
      );
    } on http.ClientException catch (error) {
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: 'Không thể kết nối đến máy chủ',
        details: error.message,
      );
    }
  }

  Future<String?> _refreshAccessToken() async {
    final activeRefresh = _refreshAccessTokenFuture;
    if (activeRefresh != null) {
      return activeRefresh;
    }

    final callback = onRefreshAccessToken;
    if (callback == null) {
      return null;
    }

    final refreshFuture = Future<String?>.sync(callback);
    _refreshAccessTokenFuture = refreshFuture;
    try {
      return await refreshFuture;
    } catch (_) {
      return null;
    } finally {
      if (identical(_refreshAccessTokenFuture, refreshFuture)) {
        _refreshAccessTokenFuture = null;
      }
    }
  }

  Future<void> _handleUnauthorized() async {
    final callback = onUnauthorized;
    if (callback == null || _isHandlingUnauthorized) {
      return;
    }

    _isHandlingUnauthorized = true;
    try {
      await callback();
    } catch (_) {
      // Preserve the original API error even if local session cleanup fails.
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  Map<String, String> _headers(String? accessToken) {
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  Object? _parseResponse(http.Response response) {
    final Map<String, dynamic> payload;

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response is not a JSON object');
      }
      payload = decoded;
    } on FormatException catch (error) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Phản hồi từ máy chủ không hợp lệ',
        statusCode: response.statusCode,
        details: error.message,
      );
    }

    final isHttpSuccess =
        response.statusCode >= 200 && response.statusCode < 300;
    if (isHttpSuccess && payload['success'] == true) {
      return payload['data'];
    }

    final error = payload['error'];
    if (error is Map<String, dynamic>) {
      throw ApiException(
        code: error['code']?.toString() ?? 'API_ERROR',
        message: error['message']?.toString() ?? 'Yêu cầu không thành công',
        statusCode: response.statusCode,
        details: error['details'],
      );
    }

    throw ApiException(
      code: 'HTTP_${response.statusCode}',
      message: payload['message']?.toString() ?? 'Yêu cầu không thành công',
      statusCode: response.statusCode,
    );
  }

  void close() {
    _httpClient.close();
  }
}
