import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/teacher_timetable_response_model.dart';
import '../models/timetable_response_model.dart';

class TimetableRemoteDatasource {
  const TimetableRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<TimetableResponseModel> getParentStudentTimetable({
    required String accessToken,
    required int studentId,
    required DateTime weekStart,
    int? semesterId,
  }) {
    return _getTimetable(
      path: '/parent/students/$studentId/timetable',
      accessToken: accessToken,
      semesterId: semesterId,
      weekStart: weekStart,
      parser: TimetableResponseModel.fromJson,
    );
  }

  Future<TimetableResponseModel> getStudentTimetable({
    required String accessToken,
    required DateTime weekStart,
    int? semesterId,
  }) {
    return _getTimetable(
      path: '/student/me/timetable',
      accessToken: accessToken,
      semesterId: semesterId,
      weekStart: weekStart,
      parser: TimetableResponseModel.fromJson,
    );
  }

  Future<TeacherTimetableResponseModel> getTeacherTimetable({
    required String accessToken,
    required DateTime weekStart,
    int? semesterId,
  }) {
    return _getTimetable(
      path: '/teacher/me/timetable',
      accessToken: accessToken,
      semesterId: semesterId,
      weekStart: weekStart,
      parser: TeacherTimetableResponseModel.fromJson,
    );
  }

  Future<T> _getTimetable<T>({
    required String path,
    required String accessToken,
    required DateTime weekStart,
    required T Function(Map<String, dynamic>) parser,
    int? semesterId,
  }) async {
    final query = Uri(
      queryParameters: <String, String>{
        'weekStart': _formatDate(weekStart),
        if (semesterId != null) 'semesterId': semesterId.toString(),
      },
    ).query;
    final data = await _apiClient.get('$path?$query', accessToken: accessToken);

    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu thời khóa biểu từ máy chủ không hợp lệ',
      );
    }

    try {
      return parser(data);
    } on FormatException catch (error) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu thời khóa biểu từ máy chủ không hợp lệ',
        details: error.message,
      );
    } on TypeError catch (error) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu thời khóa biểu từ máy chủ không hợp lệ',
        details: error.toString(),
      );
    }
  }

  String _formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().substring(0, 10);
  }
}
