import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/account.dart';
import '../../../home/presentation/pages/parent_home_page.dart';
import '../../../home/presentation/pages/student_home_page.dart';
import '../../../home/presentation/pages/teacher_home_page.dart';
import '../../../homeroom/presentation/controllers/homeroom_controller.dart';
import '../../../homeroom/presentation/pages/homeroom_page.dart';
import '../../../learning_result/presentation/controllers/learning_result_controller.dart';
import '../../../learning_result/presentation/pages/learning_result_page.dart';
import '../../../leave_absence/presentation/controllers/parent_leave_request_controller.dart';
import '../../../leave_absence/presentation/controllers/teacher_leave_request_controller.dart';
import '../../../leave_absence/presentation/pages/parent_leave_request_page.dart';
import '../../../leave_absence/presentation/pages/teacher_leave_request_page.dart';
import '../../../notification/presentation/controllers/app_notification_controller.dart';
import '../../../notification/presentation/pages/app_notification_page.dart';
import '../../../parent/presentation/controllers/parent_home_controller.dart';
import '../../../profile/presentation/pages/user_detail_page.dart';
import '../../../school_event/presentation/controllers/school_event_controller.dart';
import '../../../school_event/presentation/pages/school_event_page.dart';
import '../../../timetable/presentation/controllers/timetable_controller.dart';
import '../../../timetable/presentation/pages/timetable_page.dart';
import '../../../teacher/presentation/controllers/teacher_home_controller.dart';
import '../../../teacher_communication/presentation/controllers/teacher_communication_controller.dart';
import '../../../teacher_communication/presentation/pages/teacher_communication_page.dart';

class RoleLandingPage extends StatelessWidget {
  const RoleLandingPage({
    required this.activeRole,
    required this.account,
    required this.notificationController,
    required this.parentHomeController,
    required this.teacherHomeController,
    required this.createHomeroomController,
    required this.createParentTimetableController,
    required this.createStudentTimetableController,
    required this.createTeacherTimetableController,
    required this.createParentLearningResultController,
    required this.createStudentLearningResultController,
    required this.createParentLeaveRequestController,
    required this.createTeacherLeaveRequestController,
    required this.createParentSchoolEventController,
    required this.createStudentSchoolEventController,
    required this.createTeacherCommunicationController,
    required this.onLogout,
    required this.loginPageBuilder,
    super.key,
  });

  final String activeRole;
  final Account account;
  final AppNotificationController notificationController;
  final ParentHomeController parentHomeController;
  final TeacherHomeController teacherHomeController;
  final HomeroomController Function() createHomeroomController;
  final TimetableController Function(int studentId)
  createParentTimetableController;
  final TimetableController Function() createStudentTimetableController;
  final TimetableController Function() createTeacherTimetableController;
  final LearningResultController Function(int studentId)
  createParentLearningResultController;
  final LearningResultController Function()
  createStudentLearningResultController;
  final ParentLeaveRequestController Function(int studentId)
  createParentLeaveRequestController;
  final TeacherLeaveRequestController Function()
  createTeacherLeaveRequestController;
  final SchoolEventController Function(int studentId)
  createParentSchoolEventController;
  final SchoolEventController Function() createStudentSchoolEventController;
  final TeacherCommunicationController Function()
  createTeacherCommunicationController;
  final Future<void> Function() onLogout;
  final Widget Function() loginPageBuilder;

  static const _roleLabels = <String, String>{
    'PARENT': 'Phụ huynh',
    'STUDENT': 'Học sinh',
    'TEACHER': 'Giáo viên',
    'ADMIN': 'Quản trị viên',
  };

  @override
  Widget build(BuildContext context) {
    Future<void> logoutAndReturnToLogin() async {
      try {
        await onLogout();
      } catch (_) {
        // Logout on the server is best-effort. Local tokens and session have
        // already been cleared by the repository and controller.
      } finally {
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => loginPageBuilder()),
            (_) => false,
          );
        }
      }
    }

    void openProfile() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => UserDetailPage(
            account: account,
            onLogout: logoutAndReturnToLogin,
          ),
        ),
      );
    }

    Future<void> openParentTimetable() async {
      final selectedStudent = parentHomeController.selectedStudent;
      if (selectedStudent == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa có học sinh được chọn.')),
        );
        return;
      }
      if (selectedStudent.classId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Học sinh chưa được xếp lớp.')),
        );
        return;
      }

      final controller = createParentTimetableController(selectedStudent.id);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TimetablePage(controller: controller),
        ),
      );
      controller.dispose();
    }

    Future<void> openStudentTimetable() async {
      final controller = createStudentTimetableController();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TimetablePage(controller: controller),
        ),
      );
      controller.dispose();
    }

    Future<void> openTeacherTimetable() async {
      final controller = createTeacherTimetableController();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TimetablePage(controller: controller),
        ),
      );
      controller.dispose();
    }

    Future<void> openHomeroom() async {
      final controller = createHomeroomController();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HomeroomPage(controller: controller),
        ),
      );
      controller.dispose();
    }

    Future<void> openParentLearningResult() async {
      final selectedStudent = parentHomeController.selectedStudent;
      if (selectedStudent == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa có học sinh được chọn.')),
        );
        return;
      }

      final controller = createParentLearningResultController(
        selectedStudent.id,
      );
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LearningResultPage(controller: controller),
        ),
      );
      controller.dispose();
    }

    Future<void> openStudentLearningResult() async {
      final controller = createStudentLearningResultController();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LearningResultPage(controller: controller),
        ),
      );
      controller.dispose();
    }

    Future<void> openParentLeaveRequests() async {
      final selectedStudent = parentHomeController.selectedStudent;
      if (selectedStudent == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa có học sinh được chọn.')),
        );
        return;
      }

      final controller = createParentLeaveRequestController(selectedStudent.id);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ParentLeaveRequestPage(
            controller: controller,
            student: selectedStudent,
          ),
        ),
      );
      controller.dispose();
    }

    Future<void> openTeacherLeaveRequests() async {
      final controller = createTeacherLeaveRequestController();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TeacherLeaveRequestPage(controller: controller),
        ),
      );
      controller.dispose();
    }

    Future<void> openParentSchoolEvents() async {
      final selectedStudent = parentHomeController.selectedStudent;
      if (selectedStudent == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa có học sinh được chọn.')),
        );
        return;
      }

      final controller = createParentSchoolEventController(selectedStudent.id);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SchoolEventPage(controller: controller),
        ),
      );
      controller.dispose();
    }

    Future<void> openStudentSchoolEvents() async {
      final controller = createStudentSchoolEventController();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SchoolEventPage(controller: controller),
        ),
      );
      controller.dispose();
    }

    Future<void> openTeacherCommunication() async {
      final controller = createTeacherCommunicationController();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TeacherCommunicationPage(controller: controller),
        ),
      );
      controller.dispose();
    }

    Future<void> openNotifications() async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AppNotificationPage(
            controller: notificationController,
            onAccountTap: openProfile,
          ),
        ),
      );
    }

    if (activeRole == 'PARENT') {
      return ParentHomePage(
        controller: parentHomeController,
        notificationController: notificationController,
        onProfileTap: openProfile,
        onTimetableTap: openParentTimetable,
        onLearningResultTap: openParentLearningResult,
        onLeaveRequestTap: openParentLeaveRequests,
        onSchoolEventTap: openParentSchoolEvents,
        onNotificationTap: openNotifications,
      );
    }
    if (activeRole == 'TEACHER') {
      return TeacherHomePage(
        controller: teacherHomeController,
        onProfileTap: openProfile,
        onHomeroomTap: openHomeroom,
        onTimetableTap: openTeacherTimetable,
        onLeaveRequestTap: openTeacherLeaveRequests,
        onCommunicationTap: openTeacherCommunication,
      );
    }
    if (activeRole == 'STUDENT') {
      return StudentHomePage(
        notificationController: notificationController,
        onProfileTap: openProfile,
        onTimetableTap: openStudentTimetable,
        onLearningResultTap: openStudentLearningResult,
        onSchoolEventTap: openStudentSchoolEvents,
        onNotificationTap: openNotifications,
      );
    }

    final roleLabel = _roleLabels[activeRole] ?? activeRole;

    return Scaffold(
      appBar: AppBar(title: const Text('MyFschool')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 72,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'Đăng nhập thành công với vai trò $roleLabel',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Màn hình chính của vai trò sẽ được hoàn thiện ở feature tiếp theo.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
