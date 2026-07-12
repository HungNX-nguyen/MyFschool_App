import 'package:flutter/material.dart';

import '../../../auth/domain/entities/account.dart';
import '../../../../shared/theme/app_theme.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({
    required this.account,
    required this.onLogout,
    super.key,
  });

  final Account account;
  final Future<void> Function() onLogout;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  static const _roleLabels = <String, String>{
    'PARENT': 'Phụ huynh',
    'STUDENT': 'Học sinh',
    'TEACHER': 'Giáo viên',
    'ADMIN': 'Quản trị viên',
  };

  bool _isLoggingOut = false;

  String get _displayName {
    final fullName = widget.account.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    final username = widget.account.username?.trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }
    return 'Người dùng';
  }

  String get _roleLabel {
    final activeRole = widget.account.activeRole;
    return _roleLabels[activeRole] ?? activeRole ?? 'Chưa chọn vai trò';
  }

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    setState(() => _isLoggingOut = true);
    try {
      await widget.onLogout();
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      padding: const EdgeInsets.all(20),
                      iconSize: 42,
                      color: const Color(0xFF0878F9),
                      tooltip: 'Quay lại',
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFEAEAEA),
                    child: Icon(
                      Icons.person,
                      size: 58,
                      color: Color(0xFF686868),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _displayName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _roleLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 34),
                  const Divider(
                    thickness: 12,
                    height: 12,
                    color: Color(0xFFE7E7E7),
                  ),
                  const _ProfileMenuItem(
                    icon: Icons.account_circle_outlined,
                    iconColor: Color(0xFF2D82F7),
                    title: 'Thông tin tài khoản',
                    subtitle: 'Cập nhật thông tin',
                  ),
                  const _ProfileMenuItem(
                    icon: Icons.info,
                    iconColor: AppTheme.primaryColor,
                    title: 'Phiên bản',
                    subtitle: '1.0',
                  ),
                  const _ProfileMenuItem(
                    icon: Icons.lock,
                    iconColor: Color(0xFF666666),
                    title: 'Cài đặt',
                    subtitle: 'Quyền riêng tư và mật khẩu',
                  ),
                  const SizedBox(height: 70),
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 58,
                      child: FilledButton.icon(
                        onPressed: _isLoggingOut ? null : _logout,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: _isLoggingOut
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.logout, size: 30),
                        label: Text(
                          _isLoggingOut ? 'Đang đăng xuất...' : 'Đăng xuất',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Container(
        constraints: const BoxConstraints(minHeight: 94),
        padding: const EdgeInsets.only(right: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFD8D8D8))),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF666666),
              size: 34,
            ),
          ],
        ),
      ),
    );
  }
}
