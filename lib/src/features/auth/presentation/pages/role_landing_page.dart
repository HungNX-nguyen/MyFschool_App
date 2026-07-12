import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../home/presentation/pages/parent_home_page.dart';
import '../../../home/presentation/pages/student_home_page.dart';
import '../../../home/presentation/pages/teacher_home_page.dart';

class RoleLandingPage extends StatelessWidget {
  const RoleLandingPage({
    required this.activeRole,
    super.key,
  });

  final String activeRole;

  static const _roleLabels = <String, String>{
    'PARENT': 'Phụ huynh',
    'STUDENT': 'Học sinh',
    'TEACHER': 'Giáo viên',
    'ADMIN': 'Quản trị viên',
  };

  @override
  Widget build(BuildContext context) {
    if (activeRole == 'PARENT') {
      return const ParentHomePage();
    }
    if (activeRole == 'TEACHER') {
      return const TeacherHomePage();
    }
    if (activeRole == 'STUDENT') {
      return const StudentHomePage();
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
