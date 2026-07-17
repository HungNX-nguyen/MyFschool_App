import '../entities/teacher_communication.dart';

abstract interface class TeacherCommunicationRepository {
  Future<List<ActiveHomeroomClass>> getActiveHomeroomClasses();

  Future<ClassNotificationSendResult> sendClassNotification({
    required int classId,
    required String title,
    required String content,
    required ClassNotificationAudience audience,
  });

  Future<ClassEventCreationResult> createClassEvent({
    required int classId,
    required CreateTeacherClassEvent event,
  });
}
