import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/homeroom_class_model.dart';
import '../models/homeroom_roster_model.dart';
import '../models/homeroom_timetable_model.dart';

class HomeroomRemoteDatasource {
  const HomeroomRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<HomeroomClassSummaryModel>> getHomeroomClasses({
    required String accessToken,
  }) async {
    final data = await _apiClient.get(
      '/teacher/homeroom/classes',
      accessToken: accessToken,
    );
    if (data is! List<dynamic>) {
      throw _invalidResponse('Homeroom classes must be a list');
    }

    try {
      return List<HomeroomClassSummaryModel>.unmodifiable(
        data.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Homeroom class must be an object');
          }
          return HomeroomClassSummaryModel.fromJson(item);
        }),
      );
    } on FormatException catch (error) {
      throw _invalidResponse(error.message);
    } on TypeError catch (error) {
      throw _invalidResponse(error.toString());
    }
  }

  Future<HomeroomClassRosterModel> getClassRoster({
    required String accessToken,
    required int classId,
  }) async {
    final data = await _apiClient.get(
      '/teacher/homeroom/classes/$classId/students',
      accessToken: accessToken,
    );
    return _parseObject(data, HomeroomClassRosterModel.fromJson);
  }

  Future<HomeroomTimetableModel> getClassTimetable({
    required String accessToken,
    required int classId,
    required DateTime weekStart,
    int? semesterId,
    int? studyGroupId,
  }) async {
    final query = Uri(
      queryParameters: <String, String>{
        'weekStart': _formatDate(weekStart),
        if (semesterId != null) 'semesterId': semesterId.toString(),
        if (studyGroupId != null) 'studyGroupId': studyGroupId.toString(),
      },
    ).query;
    final data = await _apiClient.get(
      '/teacher/homeroom/classes/$classId/timetable?$query',
      accessToken: accessToken,
    );
    return _parseObject(data, HomeroomTimetableModel.fromJson);
  }

  T _parseObject<T>(Object? data, T Function(Map<String, dynamic>) parser) {
    if (data is! Map<String, dynamic>) {
      throw _invalidResponse('Homeroom response must be an object');
    }
    try {
      return parser(data);
    } on FormatException catch (error) {
      throw _invalidResponse(error.message);
    } on TypeError catch (error) {
      throw _invalidResponse(error.toString());
    }
  }

  String _formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().substring(0, 10);
  }

  ApiException _invalidResponse(String details) {
    return ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Dữ liệu lớp chủ nhiệm từ máy chủ không hợp lệ',
      details: details,
    );
  }
}
