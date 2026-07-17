import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/home/presentation/pages/teacher_home_page.dart';
import 'package:myfschoolse1913/src/features/teacher/domain/entities/teacher_home_summary.dart';
import 'package:myfschoolse1913/src/features/teacher/domain/repositories/teacher_repository.dart';
import 'package:myfschoolse1913/src/features/teacher/presentation/controllers/teacher_home_controller.dart';

void main() {
  testWidgets('renders the teacher home content on a Pixel 6 Pro viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var leaveRequestTapCount = 0;
    var communicationTapCount = 0;
    final controller = TeacherHomeController(_FakeTeacherRepository());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: TeacherHomePage(
          controller: controller,
          onProfileTap: () {},
          onHomeroomTap: () {},
          onTimetableTap: () {},
          onLeaveRequestTap: () => leaveRequestTapCount++,
          onCommunicationTap: () => communicationTapCount++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Lớp chủ nhiệm: 10A1'), findsOneWidget);
    expect(find.textContaining('Môn giảng dạy: Toán • 10A1'), findsOneWidget);
    expect(find.text('Lớp CN'), findsOneWidget);
    expect(find.text('Nhập điểm'), findsOneWidget);
    expect(find.text('Lịch dạy'), findsOneWidget);
    expect(find.text('Các loại phí'), findsOneWidget);
    expect(find.text('Đơn từ'), findsOneWidget);
    expect(find.text('Gửi thông báo'), findsOneWidget);
    expect(find.text('Tin tức nhà trường'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(9));
    await tester.tap(find.text('Đơn từ'));
    expect(leaveRequestTapCount, 1);
    await tester.tap(find.text('Gửi thông báo'));
    expect(communicationTapCount, 1);
    expect(tester.takeException(), isNull);
  });
}

class _FakeTeacherRepository implements TeacherRepository {
  @override
  Future<TeacherHomeSummary> getHomeSummary() async {
    return const TeacherHomeSummary(
      teacherId: 20,
      teacherCode: 'TCH001',
      teacherName: 'Giáo viên Test',
      academicYearId: 1,
      academicYearName: '2026-2027',
      homeroomClasses: [
        TeacherHomeroomClass(
          classId: 40,
          classCode: '10A1',
          className: 'Lớp 10A1',
        ),
      ],
      teachingAssignments: [
        TeacherAssignment(
          subjectId: 50,
          subjectCode: 'TOAN',
          subjectName: 'Toán',
          classId: 40,
          classCode: '10A1',
          className: 'Lớp 10A1',
        ),
      ],
    );
  }
}
