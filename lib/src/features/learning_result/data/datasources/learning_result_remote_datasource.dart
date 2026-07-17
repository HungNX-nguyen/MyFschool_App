import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/learning_result.dart';
import '../models/learning_result_response_model.dart';

class LearningResultRemoteDatasource {
  const LearningResultRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<LearningResultResponseModel> getParentStudentResult({
    required String accessToken,
    required int studentId,
    required LearningResultPeriod period,
    int? academicYearId,
  }) {
    return _getResult(
      path: '/parent/students/$studentId/learning-results',
      accessToken: accessToken,
      academicYearId: academicYearId,
      period: period,
    );
  }

  Future<LearningResultResponseModel> getStudentResult({
    required String accessToken,
    required LearningResultPeriod period,
    int? academicYearId,
  }) {
    return _getResult(
      path: '/student/me/learning-results',
      accessToken: accessToken,
      academicYearId: academicYearId,
      period: period,
    );
  }

  Future<LearningResultResponseModel> _getResult({
    required String path,
    required String accessToken,
    required LearningResultPeriod period,
    int? academicYearId,
  }) async {
    final query = Uri(
      queryParameters: <String, String>{
        'period': period.apiValue,
        if (academicYearId != null) 'academicYearId': academicYearId.toString(),
      },
    ).query;
    final data = await _apiClient.get('$path?$query', accessToken: accessToken);

    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu kết quả học tập từ máy chủ không hợp lệ',
      );
    }

    try {
      return LearningResultResponseModel.fromJson(data);
    } on FormatException catch (error) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu kết quả học tập từ máy chủ không hợp lệ',
        details: error.message,
      );
    } on TypeError catch (error) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Dữ liệu kết quả học tập từ máy chủ không hợp lệ',
        details: error.toString(),
      );
    }
  }
}
