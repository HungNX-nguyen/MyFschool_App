import 'package:flutter/material.dart';

import '../../../parent/presentation/controllers/parent_home_controller.dart';
import '../../../notification/presentation/controllers/app_notification_controller.dart';
import '../widgets/home_shared_widgets.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({
    required this.controller,
    this.notificationController,
    required this.onProfileTap,
    required this.onTimetableTap,
    required this.onLearningResultTap,
    required this.onLeaveRequestTap,
    required this.onSchoolEventTap,
    this.onNotificationTap,
    super.key,
  });

  final ParentHomeController controller;
  final AppNotificationController? notificationController;
  final VoidCallback onProfileTap;
  final VoidCallback onTimetableTap;
  final VoidCallback onLearningResultTap;
  final VoidCallback onLeaveRequestTap;
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
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
    _scheduleLoadStudents();
  }

  @override
  void didUpdateWidget(covariant ParentHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
    _scheduleLoadStudents();
  }

  void _scheduleLoadStudents() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.loadStudents();
      }
    });
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

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
                  HomeBrandHeader(onAvatarTap: widget.onProfileTap),
                  const SizedBox(height: 22),
                  _StudentSelector(controller: widget.controller),
                  const SizedBox(height: 32),
                  const HomeSectionHeader(title: 'Các chức năng'),
                  const SizedBox(height: 14),
                  HomeFeatureGrid(
                    features: ParentHomePage._features,
                    onFeatureTap: (index) {
                      if (index == 0) {
                        widget.onTimetableTap();
                      } else if (index == 1) {
                        widget.onLearningResultTap();
                      } else if (index == 4) {
                        widget.onLeaveRequestTap();
                      } else if (index == 5) {
                        widget.onSchoolEventTap();
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
        notificationController: widget.notificationController,
        onNotificationTap: widget.onNotificationTap,
        onAccountTap: widget.onProfileTap,
      ),
    );
  }
}

class _StudentSelector extends StatelessWidget {
  const _StudentSelector({required this.controller});

  final ParentHomeController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.status == ParentHomeStatus.loading ||
        controller.status == ParentHomeStatus.idle) {
      return const _StudentSelectorFrame(
        child: Row(
          children: [
            SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Đang tải học sinh liên kết...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (controller.status == ParentHomeStatus.error) {
      return _StudentSelectorFrame(
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.errorMessage ?? 'Không thể tải học sinh liên kết',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('retry-linked-students'),
              tooltip: 'Thử lại',
              onPressed: controller.loadStudents,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ],
        ),
      );
    }

    final selectedStudent = controller.selectedStudent;
    if (selectedStudent == null) {
      return const _StudentSelectorFrame(
        child: Row(
          children: [
            _StudentIcon(),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Chưa có học sinh liên kết',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final classLabel = selectedStudent.className ?? 'Chưa xếp lớp';

    return _StudentSelectorFrame(
      child: Row(
        children: [
          const _StudentIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedStudent.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lớp $classLabel • MSHS: ${selectedStudent.studentCode}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (controller.hasMultipleStudents)
            PopupMenuButton<int>(
              key: const ValueKey('linked-student-menu'),
              tooltip: 'Chọn học sinh liên kết',
              initialValue: selectedStudent.id,
              color: Colors.white,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 30,
              ),
              onSelected: controller.selectStudent,
              itemBuilder: (context) {
                return controller.students
                    .map((student) {
                      final studentClass = student.className ?? 'Chưa xếp lớp';
                      return PopupMenuItem<int>(
                        value: student.id,
                        height: 58,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Lớp $studentClass • MSHS: ${student.studentCode}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                    .toList(growable: false);
              },
            ),
        ],
      ),
    );
  }
}

class _StudentSelectorFrame extends StatelessWidget {
  const _StudentSelectorFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10BE8B),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

class _StudentIcon extends StatelessWidget {
  const _StudentIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF73D6C9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.school, color: Colors.white, size: 27),
    );
  }
}
