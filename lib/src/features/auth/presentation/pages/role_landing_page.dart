import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/account.dart';
import '../../../home/presentation/pages/parent_home_page.dart';
import '../../../home/presentation/pages/student_home_page.dart';
import '../../../home/presentation/pages/teacher_home_page.dart';
import '../../../profile/presentation/pages/user_detail_page.dart';

class RoleLandingPage extends StatelessWidget {
  const RoleLandingPage({
    required this.activeRole,
    required this.account,
    required this.onLogout,
    required this.loginPageBuilder,
    super.key,
  });

  final String activeRole;
  final Account account;
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

    if (activeRole == 'PARENT') {
      return ParentHomePage(onProfileTap: openProfile);
    }
    if (activeRole == 'TEACHER') {
      return TeacherHomePage(onProfileTap: openProfile);
    }
    if (activeRole == 'STUDENT') {
      return StudentHomePage(onProfileTap: openProfile);
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
