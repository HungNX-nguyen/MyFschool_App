import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../homeroom/presentation/controllers/homeroom_controller.dart';
import '../../../learning_result/presentation/controllers/learning_result_controller.dart';
import '../../../leave_absence/presentation/controllers/parent_leave_request_controller.dart';
import '../../../leave_absence/presentation/controllers/teacher_leave_request_controller.dart';
import '../../../notification/presentation/controllers/app_notification_controller.dart';
import '../../../parent/presentation/controllers/parent_home_controller.dart';
import '../../../school_event/presentation/controllers/school_event_controller.dart';
import '../../../timetable/presentation/controllers/timetable_controller.dart';
import '../../../teacher/presentation/controllers/teacher_home_controller.dart';
import '../../../teacher_communication/presentation/controllers/teacher_communication_controller.dart';
import '../controllers/login_controller.dart';
import '../validators/login_validator.dart';
import 'role_landing_page.dart';
import 'role_selection_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.controller,
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
    super.key,
  });

  final LoginController controller;
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

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _hasHandledSuccess = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }

    final session = widget.controller.session;
    if (!_hasHandledSuccess &&
        widget.controller.status == LoginStatus.success &&
        session != null) {
      _hasHandledSuccess = true;
      final account = session.account;
      final destination = account.requiresRoleSelection
          ? RoleSelectionPage(
              controller: widget.controller,
              notificationController: widget.notificationController,
              parentHomeController: widget.parentHomeController,
              teacherHomeController: widget.teacherHomeController,
              createHomeroomController: widget.createHomeroomController,
              createParentTimetableController:
                  widget.createParentTimetableController,
              createStudentTimetableController:
                  widget.createStudentTimetableController,
              createTeacherTimetableController:
                  widget.createTeacherTimetableController,
              createParentLearningResultController:
                  widget.createParentLearningResultController,
              createStudentLearningResultController:
                  widget.createStudentLearningResultController,
              createParentLeaveRequestController:
                  widget.createParentLeaveRequestController,
              createTeacherLeaveRequestController:
                  widget.createTeacherLeaveRequestController,
              createParentSchoolEventController:
                  widget.createParentSchoolEventController,
              createStudentSchoolEventController:
                  widget.createStudentSchoolEventController,
              createTeacherCommunicationController:
                  widget.createTeacherCommunicationController,
              roles: account.roles,
            )
          : RoleLandingPage(
              activeRole: account.activeRole ?? account.roles.first,
              account: account,
              notificationController: widget.notificationController,
              parentHomeController: widget.parentHomeController,
              teacherHomeController: widget.teacherHomeController,
              createHomeroomController: widget.createHomeroomController,
              createParentTimetableController:
                  widget.createParentTimetableController,
              createStudentTimetableController:
                  widget.createStudentTimetableController,
              createTeacherTimetableController:
                  widget.createTeacherTimetableController,
              createParentLearningResultController:
                  widget.createParentLearningResultController,
              createStudentLearningResultController:
                  widget.createStudentLearningResultController,
              createParentLeaveRequestController:
                  widget.createParentLeaveRequestController,
              createTeacherLeaveRequestController:
                  widget.createTeacherLeaveRequestController,
              createParentSchoolEventController:
                  widget.createParentSchoolEventController,
              createStudentSchoolEventController:
                  widget.createStudentSchoolEventController,
              createTeacherCommunicationController:
                  widget.createTeacherCommunicationController,
              onLogout: widget.controller.logout,
              loginPageBuilder: () => LoginPage(
                controller: widget.controller,
                notificationController: widget.notificationController,
                parentHomeController: widget.parentHomeController,
                teacherHomeController: widget.teacherHomeController,
                createHomeroomController: widget.createHomeroomController,
                createParentTimetableController:
                    widget.createParentTimetableController,
                createStudentTimetableController:
                    widget.createStudentTimetableController,
                createTeacherTimetableController:
                    widget.createTeacherTimetableController,
                createParentLearningResultController:
                    widget.createParentLearningResultController,
                createStudentLearningResultController:
                    widget.createStudentLearningResultController,
                createParentLeaveRequestController:
                    widget.createParentLeaveRequestController,
                createTeacherLeaveRequestController:
                    widget.createTeacherLeaveRequestController,
                createParentSchoolEventController:
                    widget.createParentSchoolEventController,
                createStudentSchoolEventController:
                    widget.createStudentSchoolEventController,
                createTeacherCommunicationController:
                    widget.createTeacherCommunicationController,
              ),
            );

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
      return;
    }
    setState(() {});
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    await widget.controller.login(
      identifier: _identifierController.text,
      password: _passwordController.text,
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Form(
                      key: _formKey,
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const Spacer(),
                            Image.asset(
                              'lib/asset/images/fpt-logo.png',
                              width: 224,
                              fit: BoxFit.contain,
                              semanticLabel: 'FPT Education',
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'FPT SCHOOLS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 64),
                            _LoginTextField(
                              controller: _identifierController,
                              hintText: 'Số điện thoại hoặc tên đăng nhập',
                              prefixIcon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                              validator: LoginValidator.validateIdentifier,
                            ),
                            const SizedBox(height: 22),
                            _LoginTextField(
                              controller: _passwordController,
                              hintText: 'Mật khẩu',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              validator: LoginValidator.validatePassword,
                              onFieldSubmitted: (_) => _submit(),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Hiện mật khẩu'
                                    : 'Ẩn mật khẩu',
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('Quên mật khẩu'),
                              ),
                            ),
                            if (widget.controller.errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  widget.controller.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 28),
                            SizedBox(
                              width: 300,
                              height: 56,
                              child: FilledButton(
                                onPressed: widget.controller.isLoading
                                    ? null
                                    : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: widget.controller.isLoading
                                    ? const SizedBox.square(
                                        dimension: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Đăng nhập'),
                              ),
                            ),
                            const Spacer(flex: 3),
                            const Text(
                              'version 1.0\n© 2026 My Fschools',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
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

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.textInputAction,
    required this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputAction textInputAction;
  final FormFieldValidator<String> validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF606060);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofillHints: obscureText
          ? const [AutofillHints.password]
          : const [AutofillHints.username],
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 17,
          fontStyle: FontStyle.italic,
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.black87),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
