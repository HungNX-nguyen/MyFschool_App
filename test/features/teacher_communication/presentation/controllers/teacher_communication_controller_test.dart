import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/school_event/domain/entities/school_event.dart';
import 'package:myfschoolse1913/src/features/teacher_communication/domain/entities/teacher_communication.dart';
import 'package:myfschoolse1913/src/features/teacher_communication/domain/repositories/teacher_communication_repository.dart';
import 'package:myfschoolse1913/src/features/teacher_communication/presentation/controllers/teacher_communication_controller.dart';

void main() {
  test('loads active classes and selects the first class', () async {
    final repository = _FakeTeacherCommunicationRepository();
    final controller = TeacherCommunicationController(repository);

    await controller.loadInitial();

    expect(controller.status, TeacherCommunicationPageStatus.ready);
    expect(controller.classes, hasLength(2));
    expect(controller.selectedClass?.classId, 30);
  });

  test(
    'sends notification for selected class and shows recipient count',
    () async {
      final repository = _FakeTeacherCommunicationRepository();
      final controller = TeacherCommunicationController(repository);
      await controller.loadInitial();

      final success = await controller.sendClassNotification(
        title: '  Thông báo  ',
        content: '  Nội dung  ',
        audience: ClassNotificationAudience.parentAndStudent,
      );

      expect(success, isTrue);
      expect(repository.lastClassId, 30);
      expect(repository.lastTitle, 'Thông báo');
      expect(repository.lastContent, 'Nội dung');
      expect(controller.successMessage, 'Đã gửi thông báo đến 28 tài khoản.');
    },
  );

  test('creates published class event and updates feedback', () async {
    final repository = _FakeTeacherCommunicationRepository();
    final controller = TeacherCommunicationController(repository);
    await controller.loadInitial();
    final event = CreateTeacherClassEvent(
      title: 'Họp phụ huynh',
      eventDate: DateTime(2026, 8, 15),
      isAllDay: true,
      participationType: SchoolEventParticipationType.required,
      publishNow: true,
    );

    final success = await controller.createClassEvent(event);

    expect(success, isTrue);
    expect(repository.lastEvent, same(event));
    expect(controller.successMessage, 'Đã phát hành sự kiện lớp.');
  });

  test('shows no-class message and blocks submission', () async {
    final repository = _FakeTeacherCommunicationRepository(classes: const []);
    final controller = TeacherCommunicationController(repository);
    await controller.loadInitial();

    final success = await controller.sendClassNotification(
      title: 'Thông báo',
      content: 'Nội dung',
      audience: ClassNotificationAudience.parentOnly,
    );

    expect(controller.hasNoClasses, isTrue);
    expect(success, isFalse);
    expect(
      controller.actionErrorMessage,
      TeacherCommunicationController.noClassMessage,
    );
  });
}

class _FakeTeacherCommunicationRepository
    implements TeacherCommunicationRepository {
  _FakeTeacherCommunicationRepository({List<ActiveHomeroomClass>? classes})
    : classes =
          classes ??
          const <ActiveHomeroomClass>[
            ActiveHomeroomClass(
              classId: 30,
              classCode: '10A1',
              className: 'Lớp 10A1',
              academicYearId: 1,
              academicYearName: '2026-2027',
            ),
            ActiveHomeroomClass(
              classId: 31,
              classCode: '11A1',
              className: 'Lớp 11A1',
              academicYearId: 1,
              academicYearName: '2026-2027',
            ),
          ];

  final List<ActiveHomeroomClass> classes;
  int? lastClassId;
  String? lastTitle;
  String? lastContent;
  CreateTeacherClassEvent? lastEvent;

  @override
  Future<List<ActiveHomeroomClass>> getActiveHomeroomClasses() async => classes;

  @override
  Future<ClassNotificationSendResult> sendClassNotification({
    required int classId,
    required String title,
    required String content,
    required ClassNotificationAudience audience,
  }) async {
    lastClassId = classId;
    lastTitle = title;
    lastContent = content;
    return ClassNotificationSendResult(
      notificationId: 100,
      recipientCount: 28,
      createdAt: DateTime(2026, 7, 17, 10, 30),
    );
  }

  @override
  Future<ClassEventCreationResult> createClassEvent({
    required int classId,
    required CreateTeacherClassEvent event,
  }) async {
    lastClassId = classId;
    lastEvent = event;
    return ClassEventCreationResult(
      eventId: 50,
      status: event.publishNow
          ? TeacherClassEventStatus.published
          : TeacherClassEventStatus.draft,
      publishedAt: event.publishNow ? DateTime(2026, 7, 17, 11) : null,
    );
  }
}
