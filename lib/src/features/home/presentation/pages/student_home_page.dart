import 'package:flutter/material.dart';

import '../widgets/home_shared_widgets.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeBrandHeader(),
                  SizedBox(height: 32),
                  HomeSectionHeader(title: 'Các chức năng'),
                  SizedBox(height: 14),
                  HomeFeatureGrid(features: _features),
                  SizedBox(height: 28),
                  HomeSectionHeader(title: 'Tin tức nhà trường'),
                  SizedBox(height: 14),
                  HomeNewsGallery(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const HomeBottomNavigation(),
    );
  }
}
