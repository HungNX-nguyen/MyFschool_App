import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 15),
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final Duration timeout;

  Future<Object?> post(
    String path, {
    Map<String, Object?>? body,
    String? accessToken,
  }) async {
    try {
      final response = await _httpClient
          .post(
            AppConfig.apiUri(path),
            headers: _headers(accessToken),
            body: jsonEncode(body ?? const <String, Object?>{}),
          )
          .timeout(timeout);

      return _parseResponse(response);
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

    final isHttpSuccess = response.statusCode >= 200 && response.statusCode < 300;
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
