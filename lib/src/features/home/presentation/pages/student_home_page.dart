import 'package:flutter/material.dart';

import '../../../notification/presentation/controllers/app_notification_controller.dart';
import '../widgets/home_shared_widgets.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({
    this.notificationController,
    required this.onProfileTap,
    required this.onTimetableTap,
    required this.onLearningResultTap,
    required this.onSchoolEventTap,
    this.onNotificationTap,
    super.key,
  });

  final AppNotificationController? notificationController;
  final VoidCallback onProfileTap;
  final VoidCallback onTimetableTap;
  final VoidCallback onLearningResultTap;
  final VoidCallback onSchoolEventTap;
  final VoidCallback? onNotificationTap;

  static const _features = <HomeFeatureItem>[
    HomeFeatureItem(
      label: 'Lịch học',
      icon: Icons.calendar_month_outlined,
      color: Color(0xFF119B13),
    ),
    HomeFeatureItem(
      label: 'KQ Học tập',
      icon: Icons.insert_chart_outlined,
      color: Color(0xFF075BA8),
    ),
    HomeFeatureItem(
      label: 'CLB',
      icon: Icons.groups_outlined,
      color: Color(0xFFE6001A),
    ),
    HomeFeatureItem(
      label: 'Đơn từ',
      icon: Icons.outgoing_mail,
      color: Color(0xFF111111),
    ),
    HomeFeatureItem(
      label: 'Sự kiện',
      icon: Icons.event_note_outlined,
      color: Color(0xFF12A7B1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeBrandHeader(onAvatarTap: onProfileTap),
                  const SizedBox(height: 32),
                  const HomeSectionHeader(title: 'Các chức năng'),
                  const SizedBox(height: 14),
                  HomeFeatureGrid(
                    features: _features,
                    onFeatureTap: (index) {
                      if (index == 0) {
                        onTimetableTap();
                      } else if (index == 1) {
                        onLearningResultTap();
                      } else if (index == 4) {
                        onSchoolEventTap();
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                  const HomeSectionHeader(title: 'Tin tức nhà trường'),
                  const SizedBox(height: 14),
                  const HomeNewsGallery(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        notificationController: notificationController,
        onNotificationTap: onNotificationTap,
        onAccountTap: onProfileTap,
      ),
    );
  }
}
