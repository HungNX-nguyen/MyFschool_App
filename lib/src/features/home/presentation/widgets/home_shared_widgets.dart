import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

class HomeBrandHeader extends StatelessWidget {
  const HomeBrandHeader({
    this.onAvatarTap,
    super.key,
  });

  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Mở tài khoản',
          child: InkWell(
            onTap: onAvatarTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF6D6D6D),
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'FPT School',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Image.asset(
          'lib/asset/images/fpt-logo.png',
          width: 76,
          height: 48,
          fit: BoxFit.contain,
          semanticLabel: 'FPT',
        ),
      ],
    );
  }
}

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    required this.title,
    this.onViewAll,
    super.key,
  });

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: onViewAll ?? () {},
          child: const Text(
            'Tất cả',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class HomeNewsGallery extends StatelessWidget {
  const HomeNewsGallery({super.key});

  static const _images = <String>[
    'lib/asset/images/news1.png',
    'lib/asset/images/news2.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 132,
          child: Row(
            children: [
              for (var index = 0; index < _images.length; index++) ...[
                if (index > 0) const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      _images[index],
                      height: 132,
                      fit: BoxFit.cover,
                      semanticLabel: 'Tin tức nhà trường ${index + 1}',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PageDot(isActive: true),
            SizedBox(width: 4),
            _PageDot(isActive: false),
          ],
        ),
      ],
    );
  }
}

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    this.onAccountTap,
    super.key,
  });

  final VoidCallback? onAccountTap;

  static const _items = <_NavigationItem>[
    _NavigationItem('Trang chủ', Icons.home),
    _NavigationItem('Trò chuyện', Icons.forum_outlined),
    _NavigationItem('Thông báo', Icons.mail_outline),
    _NavigationItem('Tài khoản', Icons.account_box_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
        ),
        child: Row(
          children: [
            for (var index = 0; index < _items.length; index++)
              Expanded(
                child: _NavigationButton(
                  item: _items[index],
                  isSelected: index == 0,
                  onTap: index == _items.length - 1 ? onAccountTap : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HomeFeatureItem {
  const HomeFeatureItem({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class HomeFeatureGrid extends StatelessWidget {
  const HomeFeatureGrid({
    required this.features,
    super.key,
  });

  final List<HomeFeatureItem> features;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
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
          childAspectRatio: 1.05,
          mainAxisSpacing: 10,
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
                Icon(feature.icon, size: 45, color: feature.color),
                const SizedBox(height: 8),
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

class _PageDot extends StatelessWidget {
  const _PageDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF555555) : Colors.white,
        border: Border.all(color: const Color(0xFF777777)),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.isSelected,
    this.onTap,
  });

  final _NavigationItem item;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFF4385F5)
        : const Color(0xFF555555);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: color, size: 26),
          const SizedBox(height: 3),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
