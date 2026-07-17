import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/timetable_week.dart';
import '../controllers/timetable_controller.dart';
import '../widgets/timetable_slot_card.dart';
import '../widgets/week_selector.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({required this.controller, super.key});

  final TimetableController controller;

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
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
  void didUpdateWidget(covariant TimetablePage oldWidget) {
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
    final controller = widget.controller;
    final isTeacher = controller.audience == TimetableAudience.teacher;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 68,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Quay lại',
          iconSize: 32,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          isTeacher ? 'Lịch dạy' : 'Thời khóa biểu',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                WeekSelector(
                  weekStart: controller.requestedWeekStart,
                  selectedDayOfWeek: controller.selectedDayOfWeek,
                  onPreviousWeek: controller.previousWeek,
                  onNextWeek: controller.nextWeek,
                  onDaySelected: controller.selectDay,
                ),
                _TableHeader(teacherView: isTeacher),
                Expanded(child: _buildContent(controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TimetableController controller) {
    final isTeacher = controller.audience == TimetableAudience.teacher;

    if (controller.status == TimetableStatus.idle ||
        controller.status == TimetableStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (controller.status == TimetableStatus.error) {
      return _ErrorState(
        message: controller.errorMessage ?? 'Không thể tải thời khóa biểu.',
        onRetry: controller.retry,
      );
    }

    final selectedDay = controller.selectedDay;
    if (selectedDay == null) {
      return const Center(child: Text('Không có dữ liệu ngày được chọn.'));
    }

    final morningSlots = selectedDay.slots
        .where((slot) => slot.shift == TimetableShift.morning)
        .toList(growable: false);
    final afternoonSlots = selectedDay.slots
        .where((slot) => slot.shift == TimetableShift.afternoon)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const TimetableShiftHeader(shift: TimetableShift.morning),
        if (morningSlots.isEmpty)
          EmptyShiftMessage(teacherView: isTeacher)
        else
          ...morningSlots.map(
            (slot) => TimetableSlotCard(slot: slot, teacherView: isTeacher),
          ),
        const TimetableShiftHeader(shift: TimetableShift.afternoon),
        if (afternoonSlots.isEmpty)
          EmptyShiftMessage(teacherView: isTeacher)
        else
          ...afternoonSlots.map(
            (slot) => TimetableSlotCard(slot: slot, teacherView: isTeacher),
          ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.teacherView});

  final bool teacherView;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        border: Border(
          top: BorderSide(color: Color(0xFFD8D8D8)),
          bottom: BorderSide(color: Color(0xFFD8D8D8)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 116,
            child: Center(
              child: Text(
                'Thời gian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Container(width: 1, color: const Color(0xFFD8D8D8)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                teacherView ? 'Môn học, lớp dạy' : 'Môn học, hoạt động',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
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
              Icons.calendar_month_outlined,
              size: 58,
              color: Color(0xFF999999),
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
