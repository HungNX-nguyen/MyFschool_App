import '../entities/homeroom_class.dart';
import '../entities/leave_request.dart';

abstract interface class LeaveRequestRepository {
  Future<List<LeaveRequest>> getParentLeaveRequests({
    required int studentId,
    LeaveRequestStatus? status,
  });

  Future<LeaveRequest> createParentLeaveRequest({
    required int studentId,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  });

  Future<LeaveRequest> cancelParentLeaveRequest(int leaveRequestId);

  Future<List<HomeroomClass>> getTeacherHomeroomClasses();

  Future<List<LeaveRequest>> getTeacherLeaveRequests({
    required int classId,
    LeaveRequestStatus? status,
  });

  Future<LeaveRequest> reviewTeacherLeaveRequest({
    required int leaveRequestId,
    required LeaveRequestDecision decision,
    String? reviewNote,
  });
}
