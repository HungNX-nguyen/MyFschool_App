enum LeaveRequestStatus { pending, approved, rejected, cancelled }

extension LeaveRequestStatusValue on LeaveRequestStatus {
  String get apiValue => switch (this) {
    LeaveRequestStatus.pending => 'PENDING',
    LeaveRequestStatus.approved => 'APPROVED',
    LeaveRequestStatus.rejected => 'REJECTED',
    LeaveRequestStatus.cancelled => 'CANCELLED',
  };
}

enum LeaveRequestDecision { approved, rejected }

extension LeaveRequestDecisionValue on LeaveRequestDecision {
  String get apiValue => switch (this) {
    LeaveRequestDecision.approved => 'APPROVED',
    LeaveRequestDecision.rejected => 'REJECTED',
  };
}

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.studentId,
    required this.studentCode,
    required this.studentName,
    required this.parentId,
    required this.parentName,
    required this.classId,
    required this.classCode,
    required this.className,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.reviewedByTeacherId,
    this.reviewedByTeacherName,
    this.reviewedAt,
    this.reviewNote,
  });

  final int id;
  final int studentId;
  final String studentCode;
  final String studentName;
  final int parentId;
  final String parentName;
  final int classId;
  final String classCode;
  final String className;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final LeaveRequestStatus status;
  final int? reviewedByTeacherId;
  final String? reviewedByTeacherName;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final DateTime createdAt;
}
