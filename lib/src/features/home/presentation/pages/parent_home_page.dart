import 'package:flutter/material.dart';

import '../widgets/home_shared_widgets.dart';

class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

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
      label: 'Thanh toán',
      icon: Icons.payments_outlined,
      color: Color(0xFFFFB000),
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
                  const HomeBrandHeader(),
                  const SizedBox(height: 22),
                  const _EmptyStudentSelector(),
                  const SizedBox(height: 32),
                  const HomeSectionHeader(title: 'Các chức năng'),
                  const SizedBox(height: 14),
                  const HomeFeatureGrid(features: _features),
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
      bottomNavigationBar: const HomeBottomNavigation(),
    );
  }
}

class _EmptyStudentSelector extends StatelessWidget {
  const _EmptyStudentSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10BE8B),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF73D6C9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 27),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Chưa có học sinh liên kết',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}
