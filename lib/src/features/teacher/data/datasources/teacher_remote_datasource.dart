import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/teacher_home_summary_model.dart';

class TeacherRemoteDatasource {
  const TeacherRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<TeacherHomeSummaryModel> getHomeSummary(String accessToken) async {
    final data = await _apiClient.get(
      '/teacher/me/home-summary',
      accessToken: accessToken,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu trang chủ giáo viên từ máy chủ không hợp lệ',
      );
    }

    try {
      return TeacherHomeSummaryModel.fromJson(data);
    } on FormatException catch (error) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu trang chủ giáo viên từ máy chủ không hợp lệ',
        details: error.message,
      );
    } on TypeError catch (error) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu trang chủ giáo viên từ máy chủ không hợp lệ',
        details: error.toString(),
      );
    }
  }
}
