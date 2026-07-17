import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/linked_student_model.dart';

class ParentRemoteDatasource {
  const ParentRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<LinkedStudentModel>> getLinkedStudents(String accessToken) async {
    final data = await _apiClient.get(
      '/parent/students',
      accessToken: accessToken,
    );

    if (data is! List<dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Danh sách học sinh liên kết từ máy chủ không hợp lệ',
      );
    }

    return data
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const ApiException(
              code: 'INVALID_RESPONSE',
              message: 'Thông tin học sinh liên kết từ máy chủ không hợp lệ',
            );
          }
          return LinkedStudentModel.fromJson(item);
        })
        .toList(growable: false);
  }
}
