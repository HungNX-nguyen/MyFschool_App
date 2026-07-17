import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/school_event/domain/entities/school_event.dart';
import 'package:myfschoolse1913/src/features/school_event/domain/repositories/school_event_repository.dart';
import 'package:myfschoolse1913/src/features/school_event/presentation/controllers/school_event_controller.dart';
import 'package:myfschoolse1913/src/features/school_event/presentation/pages/school_event_page.dart';
import 'package:myfschoolse1913/src/shared/theme/app_theme.dart';

void main() {
  testWidgets('renders and opens event detail on a Pixel 6 Pro viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = SchoolEventController(
      const _FakeSchoolEventRepository(),
      audience: SchoolEventAudience.student,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: SchoolEventPage(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sự kiện'), findsOneWidget);
    expect(find.text('Sắp tới'), findsOneWidget);
    expect(find.text('Đã qua'), findsOneWidget);
    expect(find.text('Lớp 12A1'), findsOneWidget);
    expect(find.text('Toàn trường'), findsOneWidget);
    expect(find.text('Họp phụ huynh tổng kết năm học'), findsOneWidget);
    expect(find.text('Tham quan Lăng Bác'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Họp phụ huynh tổng kết năm học'));
    await tester.pumpAndSettle();

    expect(find.text('Nội dung'), findsOneWidget);
    expect(find.text('Trao đổi kết quả học tập cuối năm.'), findsOneWidget);
    expect(find.text('15/08/2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeSchoolEventRepository implements SchoolEventRepository {
  const _FakeSchoolEventRepository();

  @override
  Future<SchoolEvent> getAccessibleEventDetail(int eventId) {
    throw UnimplementedError();
  }

  @override
  Future<SchoolEventFeed> getParentStudentEvents({
    required int studentId,
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) async {
    return _feed(studentId, timeRange, scope);
  }

  @override
  Future<SchoolEventFeed> getStudentEvents({
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) async {
    return _feed(29, timeRange, scope);
  }

  SchoolEventFeed _feed(
    int studentId,
    SchoolEventTimeRange timeRange,
    SchoolEventViewScope scope,
  ) {
    return SchoolEventFeed(
      studentId: studentId,
      classId: 3,
      classCode: '12A1',
      timeRange: timeRange,
      scope: scope,
      items: <SchoolEvent>[
        SchoolEvent(
          id: 1,
          title: 'Họp phụ huynh tổng kết năm học',
          description: 'Trao đổi kết quả học tập cuối năm.',
          scope: SchoolEventScope.classEvent,
          classId: 3,
          classCode: '12A1',
          eventDate: DateTime(2026, 8, 15),
          startTime: '08:00:00',
          endTime: '11:30:00',
          isAllDay: false,
          location: 'Lớp học 12A1',
          participationType: SchoolEventParticipationType.required,
        ),
        SchoolEvent(
          id: 2,
          title: 'Tham quan Lăng Bác',
          description: 'Hoạt động ngoại khóa.',
          scope: SchoolEventScope.school,
          eventDate: DateTime(2026, 8, 20),
          isAllDay: true,
          location: 'Hà Nội',
          participationType: SchoolEventParticipationType.optional,
        ),
      ],
    );
  }
}
