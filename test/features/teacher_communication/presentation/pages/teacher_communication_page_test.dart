import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/teacher_communication/domain/entities/teacher_communication.dart';
import 'package:myfschoolse1913/src/features/teacher_communication/domain/repositories/teacher_communication_repository.dart';
import 'package:myfschoolse1913/src/features/teacher_communication/presentation/controllers/teacher_communication_controller.dart';
import 'package:myfschoolse1913/src/features/teacher_communication/presentation/pages/teacher_communication_page.dart';

void main() {
  testWidgets('shows notification and event forms on Pixel-sized screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = TeacherCommunicationController(
      _PageRepository(withClass: true),
    );

    await tester.pumpWidget(
      MaterialApp(home: TeacherCommunicationPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'initial notification form');

    expect(find.text('Gửi thông báo'), findsWidgets);
    expect(find.textContaining('Lớp 10A1'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('notification-title-field')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('communication-event-tab')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'event form before scroll');

    expect(find.byKey(const ValueKey('event-title-field')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('publish-class-event-button')),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      find.byKey(const ValueKey('save-draft-event-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('publish-class-event-button')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull, reason: 'event form after scroll');
  });

  testWidgets('shows no assignment message when active class list is empty', (
    tester,
  ) async {
    final controller = TeacherCommunicationController(
      _PageRepository(withClass: false),
    );

    await tester.pumpWidget(
      MaterialApp(home: TeacherCommunicationPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(TeacherCommunicationController.noClassMessage),
      findsOneWidget,
    );
  });
}

class _PageRepository implements TeacherCommunicationRepository {
  _PageRepository({required this.withClass});

  final bool withClass;

  @override
  Future<List<ActiveHomeroomClass>> getActiveHomeroomClasses() async {
    if (!withClass) {
      return const <ActiveHomeroomClass>[];
    }
    return const <ActiveHomeroomClass>[
      ActiveHomeroomClass(
        classId: 30,
        classCode: '10A1',
        className: 'Lớp 10A1',
        academicYearId: 1,
        academicYearName: '2026-2027',
      ),
    ];
  }

  @override
  Future<ClassEventCreationResult> createClassEvent({
    required int classId,
    required CreateTeacherClassEvent event,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ClassNotificationSendResult> sendClassNotification({
    required int classId,
    required String title,
    required String content,
    required ClassNotificationAudience audience,
  }) {
    throw UnimplementedError();
  }
}
