import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/school_event.dart';
import '../models/school_event_model.dart';

class SchoolEventRemoteDatasource {
  const SchoolEventRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<SchoolEventModel> getAccessibleEventDetail({
    required String accessToken,
    required int eventId,
  }) async {
    final data = await _apiClient.get(
      '/school-events/$eventId',
      accessToken: accessToken,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu chi tiết sự kiện từ máy chủ không hợp lệ',
      );
    }
    try {
      return SchoolEventModel.fromJson(data);
    } on FormatException catch (error) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu chi tiết sự kiện từ máy chủ không hợp lệ',
        details: error.message,
      );
    } on TypeError catch (error) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu chi tiết sự kiện từ máy chủ không hợp lệ',
        details: error.toString(),
      );
    }
  }

  Future<SchoolEventFeedModel> getParentStudentEvents({
    required String accessToken,
    required int studentId,
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) {
    return _getEvents(
      path: '/parent/students/$studentId/events',
      accessToken: accessToken,
      timeRange: timeRange,
      scope: scope,
    );
  }

  Future<SchoolEventFeedModel> getStudentEvents({
    required String accessToken,
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) {
    return _getEvents(
      path: '/student/me/events',
      accessToken: accessToken,
      timeRange: timeRange,
      scope: scope,
    );
  }

  Future<SchoolEventFeedModel> _getEvents({
    required String path,
    required String accessToken,
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) async {
    final query = Uri(
      queryParameters: <String, String>{
        'timeRange': timeRange.apiValue,
        'scope': scope.apiValue,
      },
    ).query;
    final data = await _apiClient.get('$path?$query', accessToken: accessToken);

    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu sự kiện từ máy chủ không hợp lệ',
      );
    }

    try {
      return SchoolEventFeedModel.fromJson(data);
    } on FormatException catch (error) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu sự kiện từ máy chủ không hợp lệ',
        details: error.message,
      );
    } on TypeError catch (error) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu sự kiện từ máy chủ không hợp lệ',
        details: error.toString(),
      );
    }
  }
}
