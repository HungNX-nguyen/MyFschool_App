import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/teacher_communication_models.dart';
import '../models/teacher_communication_payloads.dart';

class TeacherCommunicationRemoteDatasource {
  const TeacherCommunicationRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ActiveHomeroomClassModel>> getActiveHomeroomClasses({
    required String accessToken,
  }) async {
    final query = Uri(
      queryParameters: const <String, String>{'academicYearStatus': 'ACTIVE'},
    ).query;
    final data = await _apiClient.get(
      '/teacher/me/homeroom-classes?$query',
      accessToken: accessToken,
    );
    if (data is! List<dynamic>) {
      throw _invalidResponse('Active homeroom classes must be a list');
    }

    try {
      return List<ActiveHomeroomClassModel>.unmodifiable(
        data.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Homeroom class must be an object');
          }
          return ActiveHomeroomClassModel.fromJson(item);
        }),
      );
    } on FormatException catch (error) {
      throw _invalidResponse(error.message);
    } on TypeError catch (error) {
      throw _invalidResponse(error.toString());
    }
  }

  Future<ClassNotificationSendResultModel> sendClassNotification({
    required String accessToken,
    required int classId,
    required SendClassNotificationPayload payload,
  }) async {
    final data = await _apiClient.post(
      '/teacher/notifications/classes/$classId',
      accessToken: accessToken,
      body: payload.toJson(),
    );
    return _parseObject(data, ClassNotificationSendResultModel.fromJson);
  }

  Future<ClassEventCreationResultModel> createClassEvent({
    required String accessToken,
    required int classId,
    required CreateClassEventPayload payload,
  }) async {
    final data = await _apiClient.post(
      '/teacher/homeroom/classes/$classId/events',
      accessToken: accessToken,
      body: payload.toJson(),
    );
    return _parseObject(data, ClassEventCreationResultModel.fromJson);
  }

  T _parseObject<T>(Object? data, T Function(Map<String, dynamic>) parser) {
    if (data is! Map<String, dynamic>) {
      throw _invalidResponse(
        'Teacher communication response must be an object',
      );
    }
    try {
      return parser(data);
    } on FormatException catch (error) {
      throw _invalidResponse(error.message);
    } on TypeError catch (error) {
      throw _invalidResponse(error.toString());
    }
  }

  ApiException _invalidResponse(String details) {
    return ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Dữ liệu gửi thông báo từ máy chủ không hợp lệ',
      details: details,
    );
  }
}
