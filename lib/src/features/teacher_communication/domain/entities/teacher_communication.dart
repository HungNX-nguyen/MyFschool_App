import '../../../school_event/domain/entities/school_event.dart';

enum ClassNotificationAudience { parentOnly, studentOnly, parentAndStudent }

extension ClassNotificationAudienceApiValue on ClassNotificationAudience {
  String get apiValue => switch (this) {
    ClassNotificationAudience.parentOnly => 'PARENT_ONLY',
    ClassNotificationAudience.studentOnly => 'STUDENT_ONLY',
    ClassNotificationAudience.parentAndStudent => 'PARENT_AND_STUDENT',
  };
}

enum TeacherClassEventStatus { draft, published }

class ActiveHomeroomClass {
  const ActiveHomeroomClass({
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
}

class ClassNotificationSendResult {
  const ClassNotificationSendResult({
    required this.notificationId,
    required this.recipientCount,
    required this.createdAt,
  });

  final int notificationId;
  final int recipientCount;
  final DateTime createdAt;
}

class CreateTeacherClassEvent {
  const CreateTeacherClassEvent({
    required this.title,
    required this.eventDate,
    required this.isAllDay,
    required this.participationType,
    required this.publishNow,
    this.description,
    this.startTime,
    this.endTime,
    this.location,
  });

  final String title;
  final String? description;
  final DateTime eventDate;
  final bool isAllDay;
  final Duration? startTime;
  final Duration? endTime;
  final String? location;
  final SchoolEventParticipationType participationType;
  final bool publishNow;
}

class ClassEventCreationResult {
  const ClassEventCreationResult({
    required this.eventId,
    required this.status,
    this.publishedAt,
  });

  final int eventId;
  final TeacherClassEventStatus status;
  final DateTime? publishedAt;
}
