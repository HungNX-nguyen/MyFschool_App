import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/homeroom_class.dart';
import '../controllers/homeroom_controller.dart';
import '../widgets/homeroom_roster_list.dart';
import '../widgets/homeroom_timetable_view.dart';

class HomeroomPage extends StatefulWidget {
  const HomeroomPage({required this.controller, super.key});

  final HomeroomController controller;

  @override
  State<HomeroomPage> createState() => _HomeroomPageState();
}

class _HomeroomPageState extends State<HomeroomPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.loadInitial();
      }
    });
  }

  @override
  void didUpdateWidget(covariant HomeroomPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.loadInitial();
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
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: AppTheme.primaryColor,
        elevation: 1,
        toolbarHeight: 66,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Quay lại',
          iconSize: 28,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Lớp chủ nhiệm',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildContent(widget.controller),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HomeroomController controller) {
    if ((controller.status == HomeroomPageStatus.idle ||
            controller.status == HomeroomPageStatus.loading) &&
        controller.classes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (controller.status == HomeroomPageStatus.error &&
        controller.classes.isEmpty) {
      return _ErrorState(
        message: controller.errorMessage ?? 'Không thể tải lớp chủ nhiệm.',
        onRetry: controller.retry,
      );
    }

    if (controller.hasNoClasses) {
      return const _NoHomeroomClass();
    }

    final selectedClass = controller.selectedClass;
    if (selectedClass == null) {
      return const _NoHomeroomClass();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: _ClassSelector(
            classes: controller.classes,
            selectedClass: selectedClass,
            onSelected: controller.selectClass,
          ),
        ),
        _TabSelector(
          selectedTab: controller.selectedTab,
          onSelected: controller.selectTab,
        ),
        Expanded(child: _buildSelectedTab(controller)),
      ],
    );
  }

  Widget _buildSelectedTab(HomeroomController controller) {
    if (controller.selectedTab == HomeroomTab.roster) {
      if (controller.isRosterLoading && controller.roster == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        );
      }
      if (controller.rosterStatus == HomeroomPageStatus.error) {
        return _ErrorState(
          message:
              controller.rosterErrorMessage ?? 'Không thể tải danh sách lớp.',
          onRetry: controller.retryRoster,
        );
      }
      final roster = controller.roster;
      if (roster == null) {
        return const Center(child: Text('Chưa có dữ liệu danh sách lớp.'));
      }
      return Column(
        children: [
          if (controller.isRosterLoading)
            const LinearProgressIndicator(color: AppTheme.primaryColor),
          Expanded(
            child: HomeroomRosterList(
              roster: roster,
              onRefresh: controller.retryRoster,
            ),
          ),
        ],
      );
    }

    return HomeroomTimetableView(
      availableSemesters: controller.availableSemesters,
      selectedSemester: controller.selectedSemester,
      weekStart: controller.requestedWeekStart,
      selectedDayOfWeek: controller.selectedDayOfWeek,
      availableStudyGroups: controller.availableStudyGroups,
      selectedStudyGroupId: controller.selectedStudyGroupId,
      selectedDay: controller.selectedDay,
      isLoading: controller.isTimetableLoading,
      canGoPreviousWeek: controller.canGoPreviousWeek,
      canGoNextWeek: controller.canGoNextWeek,
      errorMessage: controller.timetableErrorMessage,
      onSemesterSelected: controller.selectSemester,
      onDateSelected: controller.selectDate,
      onPreviousWeek: controller.previousWeek,
      onNextWeek: controller.nextWeek,
      onDaySelected: controller.selectDay,
      onStudyGroupSelected: controller.selectStudyGroup,
      onRetry: controller.retryTimetable,
    );
  }
}

class _ClassSelector extends StatelessWidget {
  const _ClassSelector({
    required this.classes,
    required this.selectedClass,
    required this.onSelected,
  });

  final List<HomeroomClassSummary> classes;
  final HomeroomClassSummary selectedClass;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 23,
            backgroundColor: Color(0xFFFFEEE5),
            foregroundColor: AppTheme.primaryColor,
            child: Icon(Icons.groups_2_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lớp chủ nhiệm',
                  style: TextStyle(color: Color(0xFF6A6A6A), fontSize: 12),
                ),
                const SizedBox(height: 3),
                if (classes.length == 1)
                  Text(
                    '${selectedClass.className} • ${selectedClass.academicYearName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                else
                  DropdownButton<int>(
                    key: const ValueKey('homeroom-class-selector'),
                    value: selectedClass.classId,
                    isExpanded: true,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        onSelected(value);
                      }
                    },
                    items: classes
                        .map(
                          (schoolClass) => DropdownMenuItem<int>(
                            value: schoolClass.classId,
                            child: Text(
                              '${schoolClass.className} • ${schoolClass.academicYearName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.selectedTab, required this.onSelected});

  final HomeroomTab selectedTab;
  final ValueChanged<HomeroomTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Danh sách lớp',
              icon: Icons.people_alt_outlined,
              selected: selectedTab == HomeroomTab.roster,
              onTap: () => onSelected(HomeroomTab.roster),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TabButton(
              label: 'Lịch học',
              icon: Icons.calendar_month_outlined,
              selected: selectedTab == HomeroomTab.timetable,
              onTap: () => onSelected(HomeroomTab.timetable),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? Colors.white : AppTheme.primaryColor,
          backgroundColor: selected ? AppTheme.primaryColor : Colors.white,
          side: const BorderSide(color: AppTheme.primaryColor),
          shape: const StadiumBorder(),
        ),
        icon: Icon(icon, size: 19),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _NoHomeroomClass extends StatelessWidget {
  const _NoHomeroomClass();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_2_outlined, size: 72, color: Color(0xFFAAAAAA)),
            SizedBox(height: 16),
            Text(
              HomeroomController.noClassMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Color(0xFF999999),
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
