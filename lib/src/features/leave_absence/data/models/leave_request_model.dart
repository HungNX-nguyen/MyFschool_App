import '../../domain/entities/leave_request.dart';

class LeaveRequestModel {
  const LeaveRequestModel({
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

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: (json['id'] as num).toInt(),
      studentId: (json['studentId'] as num).toInt(),
      studentCode: json['studentCode'] as String,
      studentName: json['studentName'] as String,
      parentId: (json['parentId'] as num).toInt(),
      parentName: json['parentName'] as String,
      classId: (json['classId'] as num).toInt(),
      classCode: json['classCode'] as String,
      className: json['className'] as String,
      fromDate: DateTime.parse(json['fromDate'] as String),
      toDate: DateTime.parse(json['toDate'] as String),
      reason: json['reason'] as String,
      status: _parseStatus(json['status'] as String),
      reviewedByTeacherId: (json['reviewedByTeacherId'] as num?)?.toInt(),
      reviewedByTeacherName: json['reviewedByTeacherName'] as String?,
      reviewedAt: _parseOptionalDateTime(json['reviewedAt']),
      reviewNote: json['reviewNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  LeaveRequest toEntity() {
    return LeaveRequest(
      id: id,
      studentId: studentId,
      studentCode: studentCode,
      studentName: studentName,
      parentId: parentId,
      parentName: parentName,
      classId: classId,
      classCode: classCode,
      className: className,
      fromDate: fromDate,
      toDate: toDate,
      reason: reason,
      status: status,
      reviewedByTeacherId: reviewedByTeacherId,
      reviewedByTeacherName: reviewedByTeacherName,
      reviewedAt: reviewedAt,
      reviewNote: reviewNote,
      createdAt: createdAt,
    );
  }

  static LeaveRequestStatus _parseStatus(String value) {
    return switch (value) {
      'PENDING' => LeaveRequestStatus.pending,
      'APPROVED' => LeaveRequestStatus.approved,
      'REJECTED' => LeaveRequestStatus.rejected,
      'CANCELLED' => LeaveRequestStatus.cancelled,
      _ => throw FormatException('Unknown leave request status: $value'),
    };
  }

  static DateTime? _parseOptionalDateTime(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw const FormatException('Review time must be a string');
    }
    return DateTime.parse(value);
  }
}
