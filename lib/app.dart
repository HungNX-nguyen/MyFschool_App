import 'package:flutter/material.dart';

import 'src/core/di/app_dependencies.dart';
import 'src/features/auth/presentation/pages/login_page.dart';
import 'src/shared/theme/app_theme.dart';

class MyFschoolApp extends StatefulWidget {
  const MyFschoolApp({super.key});

  @override
  State<MyFschoolApp> createState() => _MyFschoolAppState();
}

class _MyFschoolAppState extends State<MyFschoolApp> {
  late final AppDependencies _dependencies;

  @override
  void initState() {
    super.initState();
    _dependencies = AppDependencies.production();
  }

  @override
  void dispose() {
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFschool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: LoginPage(controller: _dependencies.loginController),
    );
  }
}
