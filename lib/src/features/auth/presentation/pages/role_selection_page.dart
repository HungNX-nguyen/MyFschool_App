import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../controllers/login_controller.dart';
import 'login_page.dart';
import 'role_landing_page.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({
    required this.controller,
    required this.roles,
    super.key,
  });

  final LoginController controller;
  final List<String> roles;

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  static const _roleLabels = <String, String>{
    'PARENT': 'Phụ huynh',
    'STUDENT': 'Học sinh',
    'TEACHER': 'Giáo viên',
    'ADMIN': 'Quản trị viên',
  };

  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }

    final session = widget.controller.session;
    if (widget.controller.status == LoginStatus.success &&
        session?.account.activeRole != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => RoleLandingPage(
            activeRole: session!.account.activeRole!,
            account: session.account,
            onLogout: widget.controller.logout,
            loginPageBuilder: () => LoginPage(
              controller: widget.controller,
            ),
          ),
        ),
      );
      return;
    }
    setState(() {});
  }

  Future<void> _selectRole(String role) async {
    setState(() => _selectedRole = role);
    await widget.controller.selectActiveRole(role);
    if (mounted && widget.controller.status == LoginStatus.error) {
      setState(() => _selectedRole = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Vui lòng chọn vai trò',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 48),
                        for (var index = 0; index < widget.roles.length; index++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: index == widget.roles.length - 1 ? 0 : 24,
                            ),
                            child: _RoleButton(
                              label: _roleLabels[widget.roles[index]] ??
                                  widget.roles[index],
                              isPrimary: index == 0,
                              isLoading: widget.controller.isLoading &&
                                  _selectedRole == widget.roles[index],
                              isDisabled: widget.controller.isLoading,
                              onPressed: () => _selectRole(widget.roles[index]),
                            ),
                          ),
                        if (widget.controller.errorMessage != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            widget.controller.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.isPrimary,
    required this.isLoading,
    required this.isDisabled,
    required this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final style = isPrimary
        ? FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          )
        : OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: const BorderSide(color: AppTheme.primaryColor, width: 2),
          );

    final child = isLoading
        ? SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isPrimary ? Colors.white : AppTheme.primaryColor,
            ),
          )
        : Text(label);

    return SizedBox(
      width: double.infinity,
      height: 80,
      child: isPrimary
          ? FilledButton(
              onPressed: isDisabled ? null : onPressed,
              style: style,
              child: child,
            )
          : OutlinedButton(
              onPressed: isDisabled ? null : onPressed,
              style: style,
              child: child,
            ),
    );
  }
}
