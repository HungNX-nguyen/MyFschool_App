import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/home/presentation/pages/parent_home_page.dart';
import 'package:myfschoolse1913/src/features/parent/domain/entities/linked_student.dart';
import 'package:myfschoolse1913/src/features/parent/domain/repositories/parent_repository.dart';
import 'package:myfschoolse1913/src/features/parent/presentation/controllers/parent_home_controller.dart';

void main() {
  testWidgets('renders the parent home content on a Pixel 6 Pro viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = ParentHomeController(
      _FakeParentRepository(const <LinkedStudent>[]),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ParentHomePage(
          controller: controller,
          onProfileTap: () {},
          onTimetableTap: () {},
          onLearningResultTap: () {},
          onLeaveRequestTap: () {},
          onSchoolEventTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chưa có học sinh liên kết'), findsOneWidget);
    expect(find.text('Các chức năng'), findsOneWidget);
    expect(find.text('Tin tức nhà trường'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows linked student data and changes child from dropdown', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const firstStudent = LinkedStudent(
      id: 1,
      studentCode: 'STU0001',
      fullName: 'Nguyễn Văn A',
      className: '10A1',
      isPrimaryContact: true,
    );
    const secondStudent = LinkedStudent(
      id: 2,
      studentCode: 'STU0002',
      fullName: 'Nguyễn Văn B',
      isPrimaryContact: false,
    );
    final controller = ParentHomeController(
      _FakeParentRepository(const <LinkedStudent>[firstStudent, secondStudent]),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ParentHomePage(
          controller: controller,
          onProfileTap: () {},
          onTimetableTap: () {},
          onLearningResultTap: () {},
          onLeaveRequestTap: () {},
          onSchoolEventTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nguyễn Văn A'), findsOneWidget);
    expect(find.text('Lớp 10A1 • MSHS: STU0001'), findsOneWidget);
    expect(find.byKey(const ValueKey('linked-student-menu')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('linked-student-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nguyễn Văn B'));
    await tester.pumpAndSettle();

    expect(controller.selectedStudent, same(secondStudent));
    expect(find.text('Lớp Chưa xếp lớp • MSHS: STU0002'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('calls learning result action from the feature grid', (
    tester,
  ) async {
    final controller = ParentHomeController(
      _FakeParentRepository(const <LinkedStudent>[]),
    );
    addTearDown(controller.dispose);
    var learningResultTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ParentHomePage(
          controller: controller,
          onProfileTap: () {},
          onTimetableTap: () {},
          onLearningResultTap: () => learningResultTapCount++,
          onLeaveRequestTap: () {},
          onSchoolEventTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('KQ Học tập'));

    expect(learningResultTapCount, 1);
  });

  testWidgets('calls leave request action from the feature grid', (
    tester,
  ) async {
    final controller = ParentHomeController(
      _FakeParentRepository(const <LinkedStudent>[]),
    );
    addTearDown(controller.dispose);
    var leaveRequestTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ParentHomePage(
          controller: controller,
          onProfileTap: () {},
          onTimetableTap: () {},
          onLearningResultTap: () {},
          onLeaveRequestTap: () => leaveRequestTapCount++,
          onSchoolEventTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final leaveRequestFeature = find.text('Đơn từ');
    await tester.ensureVisible(leaveRequestFeature);
    await tester.tap(leaveRequestFeature);

    expect(leaveRequestTapCount, 1);
  });

  testWidgets('calls school event action from the feature grid', (
    tester,
  ) async {
    final controller = ParentHomeController(
      _FakeParentRepository(const <LinkedStudent>[]),
    );
    addTearDown(controller.dispose);
    var schoolEventTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ParentHomePage(
          controller: controller,
          onProfileTap: () {},
          onTimetableTap: () {},
          onLearningResultTap: () {},
          onLeaveRequestTap: () {},
          onSchoolEventTap: () => schoolEventTapCount++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final schoolEventFeature = find.text('Sự kiện');
    await tester.ensureVisible(schoolEventFeature);
    await tester.tap(schoolEventFeature);

    expect(schoolEventTapCount, 1);
  });
}

class _FakeParentRepository implements ParentRepository {
  const _FakeParentRepository(this.students);

  final List<LinkedStudent> students;

  @override
  Future<List<LinkedStudent>> getLinkedStudents() async {
    return students;
  }
}
