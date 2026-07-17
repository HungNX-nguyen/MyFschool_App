import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../teacher/presentation/controllers/teacher_home_controller.dart';
import '../widgets/home_shared_widgets.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({
    required this.controller,
    required this.onProfileTap,
    required this.onHomeroomTap,
    required this.onTimetableTap,
    required this.onLeaveRequestTap,
    required this.onCommunicationTap,
    super.key,
  });

  final TeacherHomeController controller;
  final VoidCallback onProfileTap;
  final VoidCallback onHomeroomTap;
  final VoidCallback onTimetableTap;
  final VoidCallback onLeaveRequestTap;
  final VoidCallback onCommunicationTap;

  static const _features = <_TeacherFeature>[
    _TeacherFeature(
      'Lớp CN',
      'lib/asset/icon/class.png',
      action: _TeacherFeatureAction.homeroom,
    ),
    _TeacherFeature('Nhập điểm', 'lib/asset/icon/score.png'),
    _TeacherFeature(
      'Lịch dạy',
      'lib/asset/icon/timetable.png',
      action: _TeacherFeatureAction.timetable,
    ),
    _TeacherFeature('Các loại phí', 'lib/asset/icon/class_fee.png'),
    _TeacherFeature(
      'Đơn từ',
      'lib/asset/icon/request.png',
      action: _TeacherFeatureAction.leaveRequest,
    ),
    _TeacherFeature(
      'Gửi thông báo',
      'lib/asset/icon/announce.png',
      action: _TeacherFeatureAction.communication,
    ),
  ];

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
    unawaited(widget.controller.loadSummary());
  }

  @override
  void didUpdateWidget(covariant TeacherHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
    unawaited(widget.controller.loadSummary());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
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
                  _TeacherAssignmentHeader(controller: widget.controller),
                  const SizedBox(height: 32),
                  const HomeSectionHeader(title: 'Các chức năng'),
                  const SizedBox(height: 14),
                  _TeacherFeatureGrid(
                    features: TeacherHomePage._features,
                    onHomeroomTap: widget.onHomeroomTap,
                    onTimetableTap: widget.onTimetableTap,
                    onLeaveRequestTap: widget.onLeaveRequestTap,
                    onCommunicationTap: widget.onCommunicationTap,
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
        onAccountTap: widget.onProfileTap,
      ),
    );
  }
}

class _TeacherAssignmentHeader extends StatelessWidget {
  const _TeacherAssignmentHeader({required this.controller});

  final TeacherHomeController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.status == TeacherHomeStatus.error) {
      return _TeacherHeaderMessage(
        icon: Icons.error_outline,
        message:
            controller.errorMessage ?? 'Không thể tải thông tin giảng dạy.',
        color: const Color(0xFFB3261E),
        backgroundColor: const Color(0xFFFFEDEA),
        onRetry: controller.loadSummary,
      );
    }

    final summary = controller.summary;
    if (controller.status != TeacherHomeStatus.success || summary == null) {
      return const _TeacherHeaderMessage(
        icon: Icons.sync,
        message: 'Đang tải thông tin giảng dạy...',
        color: AppTheme.primaryColor,
        backgroundColor: Color(0xFFFFF8D6),
        showProgress: true,
      );
    }

    final homeroomText = summary.homeroomClasses.isEmpty
        ? 'Chưa có lớp chủ nhiệm'
        : summary.homeroomClasses
              .map((schoolClass) => schoolClass.classCode)
              .join(', ');
    final assignmentText = summary.teachingAssignments.isEmpty
        ? 'Chưa có phân công giảng dạy'
        : summary.teachingAssignments
              .map(
                (assignment) =>
                    '${assignment.subjectName} • ${assignment.classCode}',
              )
              .join('; ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EC),
        border: Border.all(color: const Color(0xFFFFD3BD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeacherHeaderLine(
            icon: Icons.groups_2_outlined,
            label: 'Lớp chủ nhiệm',
            value: homeroomText,
          ),
          const SizedBox(height: 9),
          _TeacherHeaderLine(
            icon: Icons.menu_book_outlined,
            label: 'Môn giảng dạy',
            value: assignmentText,
          ),
        ],
      ),
    );
  }
}

class _TeacherHeaderLine extends StatelessWidget {
  const _TeacherHeaderLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 9),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _TeacherHeaderMessage extends StatelessWidget {
  const _TeacherHeaderMessage({
    required this.icon,
    required this.message,
    required this.color,
    required this.backgroundColor,
    this.onRetry,
    this.showProgress = false,
  });

  final IconData icon;
  final String message;
  final Color color;
  final Color backgroundColor;
  final Future<void> Function()? onRetry;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (showProgress)
            SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          if (onRetry != null)
            IconButton(
              tooltip: 'Thử lại',
              visualDensity: VisualDensity.compact,
              onPressed: () => onRetry!(),
              icon: Icon(Icons.refresh, color: color),
            ),
        ],
      ),
    );
  }
}

class _TeacherFeatureGrid extends StatelessWidget {
  const _TeacherFeatureGrid({
    required this.features,
    required this.onHomeroomTap,
    required this.onTimetableTap,
    required this.onLeaveRequestTap,
    required this.onCommunicationTap,
  });

  final List<_TeacherFeature> features;
  final VoidCallback onHomeroomTap;
  final VoidCallback onTimetableTap;
  final VoidCallback onLeaveRequestTap;
  final VoidCallback onCommunicationTap;

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
          final onTap = switch (feature.action) {
            _TeacherFeatureAction.homeroom => onHomeroomTap,
            _TeacherFeatureAction.timetable => onTimetableTap,
            _TeacherFeatureAction.leaveRequest => onLeaveRequestTap,
            _TeacherFeatureAction.communication => onCommunicationTap,
            _TeacherFeatureAction.none => null,
          };
          return InkWell(
            onTap: onTap,
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
  const _TeacherFeature(
    this.label,
    this.assetPath, {
    this.action = _TeacherFeatureAction.none,
  });

  final String label;
  final String assetPath;
  final _TeacherFeatureAction action;
}

enum _TeacherFeatureAction {
  none,
  homeroom,
  timetable,
  leaveRequest,
  communication,
}
