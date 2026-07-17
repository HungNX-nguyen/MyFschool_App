import 'dart:async';

import 'package:flutter/material.dart';

import 'src/core/di/app_dependencies.dart';
import 'src/features/auth/presentation/controllers/login_controller.dart';
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/shared/theme/app_theme.dart';

class MyFschoolApp extends StatefulWidget {
  const MyFschoolApp({super.key});

  @override
  State<MyFschoolApp> createState() => _MyFschoolAppState();
}

class _MyFschoolAppState extends State<MyFschoolApp>
    with WidgetsBindingObserver {
  late final AppDependencies _dependencies;
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _isRedirectingExpiredSession = false;

  @override
  void initState() {
    super.initState();
    _dependencies = AppDependencies.production();
    _dependencies.loginController.addListener(_handleLoginStateChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dependencies.loginController.removeListener(_handleLoginStateChanged);
    _dependencies.dispose();
    super.dispose();
  }

  void _handleLoginStateChanged() {
    final status = _dependencies.loginController.status;
    if (status == LoginStatus.success) {
      _isRedirectingExpiredSession = false;
      if (!_dependencies.inactivitySessionController.isMonitoring) {
        _dependencies.inactivitySessionController.start();
      }
      return;
    }
    if (status == LoginStatus.idle || status == LoginStatus.sessionExpired) {
      _dependencies.inactivitySessionController.stop();
      _dependencies.notificationController.reset();
    }
    if (status != LoginStatus.sessionExpired || _isRedirectingExpiredSession) {
      return;
    }

    _isRedirectingExpiredSession = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _dependencies.loginController.status != LoginStatus.sessionExpired) {
        _isRedirectingExpiredSession = false;
        return;
      }

      final navigator = _navigatorKey.currentState;
      if (navigator == null) {
        _isRedirectingExpiredSession = false;
        return;
      }

      navigator.pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => _buildLoginPage()),
        (_) => false,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_dependencies.inactivitySessionController.checkForTimeout());
    }
  }

  LoginPage _buildLoginPage() {
    return LoginPage(
      controller: _dependencies.loginController,
      notificationController: _dependencies.notificationController,
      parentHomeController: _dependencies.parentHomeController,
      teacherHomeController: _dependencies.teacherHomeController,
      createHomeroomController: _dependencies.createHomeroomController,
      createParentTimetableController:
          _dependencies.createParentTimetableController,
      createStudentTimetableController:
          _dependencies.createStudentTimetableController,
      createTeacherTimetableController:
          _dependencies.createTeacherTimetableController,
      createParentLearningResultController:
          _dependencies.createParentLearningResultController,
      createStudentLearningResultController:
          _dependencies.createStudentLearningResultController,
      createParentLeaveRequestController:
          _dependencies.createParentLeaveRequestController,
      createTeacherLeaveRequestController:
          _dependencies.createTeacherLeaveRequestController,
      createParentSchoolEventController:
          _dependencies.createParentSchoolEventController,
      createStudentSchoolEventController:
          _dependencies.createStudentSchoolEventController,
      createTeacherCommunicationController:
          _dependencies.createTeacherCommunicationController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'MyFschool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            _dependencies.inactivitySessionController.recordActivity();
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _buildLoginPage(),
    );
  }
}
