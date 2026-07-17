import '../../domain/entities/teacher_communication.dart';

class ActiveHomeroomClassModel {
  const ActiveHomeroomClassModel({
    required this.classId,
    required this.classCode,
    required this.className,
    required this.academicYearId,
    required this.academicYearName,
  });

  final int classId;
  final String classCode;
  final String className;
  final int academicYearId;
  final String academicYearName;

  factory ActiveHomeroomClassModel.fromJson(Map<String, dynamic> json) {
    return ActiveHomeroomClassModel(
      classId: (json['classId'] as num).toInt(),
      classCode: json['classCode'] as String,
      className: json['className'] as String,
      academicYearId: (json['academicYearId'] as num).toInt(),
      academicYearName: json['academicYearName'] as String,
    );
  }

  ActiveHomeroomClass toEntity() {
    return ActiveHomeroomClass(
      classId: classId,
      classCode: classCode,
      className: className,
      academicYearId: academicYearId,
      academicYearName: academicYearName,
    );
  }
}

class ClassNotificationSendResultModel {
  const ClassNotificationSendResultModel({
    required this.notificationId,
    required this.recipientCount,
    required this.createdAt,
  });

  final int notificationId;
  final int recipientCount;
  final DateTime createdAt;

  factory ClassNotificationSendResultModel.fromJson(Map<String, dynamic> json) {
    return ClassNotificationSendResultModel(
      notificationId: (json['notificationId'] as num).toInt(),
      recipientCount: (json['recipientCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  ClassNotificationSendResult toEntity() {
    return ClassNotificationSendResult(
      notificationId: notificationId,
      recipientCount: recipientCount,
      createdAt: createdAt,
    );
  }
}

class ClassEventCreationResultModel {
  const ClassEventCreationResultModel({
    required this.eventId,
    required this.status,
    this.publishedAt,
  });

  final int eventId;
  final TeacherClassEventStatus status;
  final DateTime? publishedAt;

  factory ClassEventCreationResultModel.fromJson(Map<String, dynamic> json) {
    final rawPublishedAt = json['publishedAt'];
    return ClassEventCreationResultModel(
      eventId: (json['eventId'] as num).toInt(),
      status: _parseEventStatus(json['status']),
      publishedAt: rawPublishedAt is String
          ? DateTime.parse(rawPublishedAt)
          : null,
    );
  }

  ClassEventCreationResult toEntity() {
    return ClassEventCreationResult(
      eventId: eventId,
      status: status,
      publishedAt: publishedAt,
    );
  }
}

TeacherClassEventStatus _parseEventStatus(Object? value) {
  return switch (value) {
    'DRAFT' => TeacherClassEventStatus.draft,
    'PUBLISHED' => TeacherClassEventStatus.published,
    _ => throw FormatException('Unknown class event status: $value'),
  };
}
