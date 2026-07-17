import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/leave_request.dart';
import '../models/create_leave_request_payload.dart';
import '../models/homeroom_class_model.dart';
import '../models/leave_request_model.dart';
import '../models/review_leave_request_payload.dart';

class LeaveAbsenceRemoteDatasource {
  const LeaveAbsenceRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<LeaveRequestModel>> getParentLeaveRequests({
    required String accessToken,
    required int studentId,
    LeaveRequestStatus? status,
  }) async {
    final data = await _apiClient.get(
      _withStatus('/parent/students/$studentId/leave-requests', status),
      accessToken: accessToken,
    );
    return _parseLeaveRequestList(data);
  }

  Future<LeaveRequestModel> createParentLeaveRequest({
    required String accessToken,
    required int studentId,
    required CreateLeaveRequestPayload payload,
  }) async {
    final data = await _apiClient.post(
      '/parent/students/$studentId/leave-requests',
      accessToken: accessToken,
      body: payload.toJson(),
    );
    return _parseLeaveRequest(data);
  }

  Future<LeaveRequestModel> cancelParentLeaveRequest({
    required String accessToken,
    required int leaveRequestId,
  }) async {
    final data = await _apiClient.patch(
      '/parent/leave-requests/$leaveRequestId/cancel',
      accessToken: accessToken,
    );
    return _parseLeaveRequest(data);
  }

  Future<List<HomeroomClassModel>> getTeacherHomeroomClasses({
    required String accessToken,
  }) async {
    final data = await _apiClient.get(
      '/teacher/me/homeroom-classes',
      accessToken: accessToken,
    );
    if (data is! List<dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Danh sách lớp chủ nhiệm từ máy chủ không hợp lệ',
      );
    }
    try {
      return data
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Homeroom class must be an object');
            }
            return HomeroomClassModel.fromJson(item);
          })
          .toList(growable: false);
    } on FormatException catch (error) {
      throw _invalidResponse(error.message);
    } on TypeError catch (error) {
      throw _invalidResponse(error.toString());
    }
  }

  Future<List<LeaveRequestModel>> getTeacherLeaveRequests({
    required String accessToken,
    required int classId,
    LeaveRequestStatus? status,
  }) async {
    final data = await _apiClient.get(
      _withStatus('/teacher/homeroom/classes/$classId/leave-requests', status),
      accessToken: accessToken,
    );
    return _parseLeaveRequestList(data);
  }

  Future<LeaveRequestModel> reviewTeacherLeaveRequest({
    required String accessToken,
    required int leaveRequestId,
    required ReviewLeaveRequestPayload payload,
  }) async {
    final data = await _apiClient.patch(
      '/teacher/leave-requests/$leaveRequestId/review',
      accessToken: accessToken,
      body: payload.toJson(),
    );
    return _parseLeaveRequest(data);
  }

  String _withStatus(String path, LeaveRequestStatus? status) {
    if (status == null) {
      return path;
    }
    final query = Uri(
      queryParameters: <String, String>{'status': status.apiValue},
    ).query;
    return '$path?$query';
  }

  List<LeaveRequestModel> _parseLeaveRequestList(Object? data) {
    if (data is! List<dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Danh sách đơn từ máy chủ không hợp lệ',
      );
    }
    try {
      return data
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Leave request must be an object');
            }
            return LeaveRequestModel.fromJson(item);
          })
          .toList(growable: false);
    } on FormatException catch (error) {
      throw _invalidResponse(error.message);
    } on TypeError catch (error) {
      throw _invalidResponse(error.toString());
    }
  }

  LeaveRequestModel _parseLeaveRequest(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Thông tin đơn từ máy chủ không hợp lệ',
      );
    }
    try {
      return LeaveRequestModel.fromJson(data);
    } on FormatException catch (error) {
      throw _invalidResponse(error.message);
    } on TypeError catch (error) {
      throw _invalidResponse(error.toString());
    }
  }

  ApiException _invalidResponse(String details) {
    return ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Dữ liệu đơn từ máy chủ không hợp lệ',
      details: details,
    );
  }
}
