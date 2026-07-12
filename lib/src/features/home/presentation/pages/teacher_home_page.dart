import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../widgets/home_shared_widgets.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({
    required this.onProfileTap,
    super.key,
  });

  final VoidCallback onProfileTap;

  static const _features = <_TeacherFeature>[
    _TeacherFeature('Lớp CN', 'lib/asset/icon/class.png'),
    _TeacherFeature('Nhập điểm', 'lib/asset/icon/score.png'),
    _TeacherFeature('Lịch dạy', 'lib/asset/icon/timetable.png'),
    _TeacherFeature('Các loại phí', 'lib/asset/icon/class_fee.png'),
    _TeacherFeature('Đơn từ', 'lib/asset/icon/request.png'),
    _TeacherFeature('Gửi thông báo', 'lib/asset/icon/announce.png'),
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
                  const SizedBox(height: 22),
                  const _EmptyHomeroomClass(),
                  const SizedBox(height: 32),
                  const HomeSectionHeader(title: 'Các chức năng'),
                  const SizedBox(height: 14),
                  const _TeacherFeatureGrid(features: _features),
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
        onAccountTap: onProfileTap,
      ),
    );
  }
}

class _EmptyHomeroomClass extends StatelessWidget {
  const _EmptyHomeroomClass();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8D6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Chưa có lớp chủ nhiệm',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TeacherFeatureGrid extends StatelessWidget {
  const _TeacherFeatureGrid({required this.features});

  final List<_TeacherFeature> features;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E2E2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: features.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.95,
          mainAxisSpacing: 12,
          crossAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          final feature = features[index];
          return InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      heightFactor: 0.6,
                      child: Image.asset(
                        feature.assetPath,
                        fit: BoxFit.contain,
                        semanticLabel: feature.label,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  feature.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TeacherFeature {
  const _TeacherFeature(this.label, this.assetPath);

  final String label;
  final String assetPath;
}
