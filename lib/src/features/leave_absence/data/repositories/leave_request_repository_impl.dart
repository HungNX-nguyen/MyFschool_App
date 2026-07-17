import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/homeroom_class.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/repositories/leave_request_repository.dart';
import '../datasources/leave_absence_remote_datasource.dart';
import '../models/create_leave_request_payload.dart';
import '../models/review_leave_request_payload.dart';

class LeaveRequestRepositoryImpl implements LeaveRequestRepository {
  const LeaveRequestRepositoryImpl(
    this._remoteDatasource,
    this._sessionStorage,
  );

  final LeaveAbsenceRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  @override
  Future<List<LeaveRequest>> getParentLeaveRequests({
    required int studentId,
    LeaveRequestStatus? status,
  }) async {
    final models = await _remoteDatasource.getParentLeaveRequests(
      accessToken: await _requireAccessToken(),
      studentId: studentId,
      status: status,
    );
    return List<LeaveRequest>.unmodifiable(
      models.map((model) => model.toEntity()),
    );
  }

  @override
  Future<LeaveRequest> createParentLeaveRequest({
    required int studentId,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    final model = await _remoteDatasource.createParentLeaveRequest(
      accessToken: await _requireAccessToken(),
      studentId: studentId,
      payload: CreateLeaveRequestPayload(
        fromDate: fromDate,
        toDate: toDate,
        reason: reason,
      ),
    );
    return model.toEntity();
  }

  @override
  Future<LeaveRequest> cancelParentLeaveRequest(int leaveRequestId) async {
    final model = await _remoteDatasource.cancelParentLeaveRequest(
      accessToken: await _requireAccessToken(),
      leaveRequestId: leaveRequestId,
    );
    return model.toEntity();
  }

  @override
  Future<List<HomeroomClass>> getTeacherHomeroomClasses() async {
    final models = await _remoteDatasource.getTeacherHomeroomClasses(
      accessToken: await _requireAccessToken(),
    );
    return List<HomeroomClass>.unmodifiable(
      models.map((model) => model.toEntity()),
    );
  }

  @override
  Future<List<LeaveRequest>> getTeacherLeaveRequests({
    required int classId,
    LeaveRequestStatus? status,
  }) async {
    final models = await _remoteDatasource.getTeacherLeaveRequests(
      accessToken: await _requireAccessToken(),
      classId: classId,
      status: status,
    );
    return List<LeaveRequest>.unmodifiable(
      models.map((model) => model.toEntity()),
    );
  }

  @override
  Future<LeaveRequest> reviewTeacherLeaveRequest({
    required int leaveRequestId,
    required LeaveRequestDecision decision,
    String? reviewNote,
  }) async {
    final model = await _remoteDatasource.reviewTeacherLeaveRequest(
      accessToken: await _requireAccessToken(),
      leaveRequestId: leaveRequestId,
      payload: ReviewLeaveRequestPayload(
        decision: decision,
        reviewNote: reviewNote,
      ),
    );
    return model.toEntity();
  }

  Future<String> _requireAccessToken() async {
    final accessToken = await _sessionStorage.readAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        code: 'AUTH_SESSION_MISSING',
        message: 'Phiên đăng nhập không tồn tại',
      );
    }
    return accessToken;
  }
}
