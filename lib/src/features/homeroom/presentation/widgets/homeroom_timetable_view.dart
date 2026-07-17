import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../timetable/domain/entities/timetable_week.dart';
import '../../../timetable/presentation/widgets/timetable_slot_card.dart';
import '../../../timetable/presentation/widgets/week_selector.dart';
import '../../domain/entities/homeroom_class.dart';
import '../../domain/entities/homeroom_timetable.dart';

class HomeroomTimetableView extends StatelessWidget {
  const HomeroomTimetableView({
    required this.availableSemesters,
    required this.selectedSemester,
    required this.weekStart,
    required this.selectedDayOfWeek,
    required this.availableStudyGroups,
    required this.selectedStudyGroupId,
    required this.selectedDay,
    required this.isLoading,
    required this.canGoPreviousWeek,
    required this.canGoNextWeek,
    required this.onSemesterSelected,
    required this.onDateSelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onDaySelected,
    required this.onStudyGroupSelected,
    required this.onRetry,
    this.errorMessage,
    super.key,
  });

  final List<HomeroomSemester> availableSemesters;
  final HomeroomSemester? selectedSemester;
  final DateTime weekStart;
  final int selectedDayOfWeek;
  final List<HomeroomStudyGroup> availableStudyGroups;
  final int? selectedStudyGroupId;
  final TimetableDay? selectedDay;
  final bool isLoading;
  final bool canGoPreviousWeek;
  final bool canGoNextWeek;
  final String? errorMessage;
  final ValueChanged<int> onSemesterSelected;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final ValueChanged<int> onDaySelected;
  final ValueChanged<int?> onStudyGroupSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('homeroom-timetable-view'),
      children: [
        _PeriodSelector(
          semesters: availableSemesters,
          selectedSemester: selectedSemester,
          weekStart: weekStart,
          selectedDayOfWeek: selectedDayOfWeek,
          enabled: !isLoading,
          onSemesterSelected: onSemesterSelected,
          onDateSelected: onDateSelected,
        ),
        if (availableStudyGroups.isNotEmpty)
          _StudyGroupSelector(
            groups: availableStudyGroups,
            selectedId: selectedStudyGroupId,
            onSelected: onStudyGroupSelected,
          ),
        WeekSelector(
          weekStart: weekStart,
          selectedDayOfWeek: selectedDayOfWeek,
          onPreviousWeek: canGoPreviousWeek ? onPreviousWeek : null,
          onNextWeek: canGoNextWeek ? onNextWeek : null,
          onDaySelected: onDaySelected,
        ),
        if (isLoading)
          const LinearProgressIndicator(color: AppTheme.primaryColor),
        const _TableHeader(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    final message = errorMessage;
    if (message != null) {
      return _InlineError(message: message, onRetry: onRetry);
    }

    final day = selectedDay;
    if (isLoading && day == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }
    if (day == null) {
      return const Center(child: Text('Không có dữ liệu ngày được chọn.'));
    }

    final morningSlots = day.slots
        .where((slot) => slot.shift == TimetableShift.morning)
        .toList(growable: false);
    final afternoonSlots = day.slots
        .where((slot) => slot.shift == TimetableShift.afternoon)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const TimetableShiftHeader(shift: TimetableShift.morning),
        if (morningSlots.isEmpty)
          const EmptyShiftMessage()
        else
          ...morningSlots.map(
            (slot) => TimetableSlotCard(slot: slot, showStudyGroup: true),
          ),
        const TimetableShiftHeader(shift: TimetableShift.afternoon),
        if (afternoonSlots.isEmpty)
          const EmptyShiftMessage()
        else
          ...afternoonSlots.map(
            (slot) => TimetableSlotCard(slot: slot, showStudyGroup: true),
          ),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.semesters,
    required this.selectedSemester,
    required this.weekStart,
    required this.selectedDayOfWeek,
    required this.enabled,
    required this.onSemesterSelected,
    required this.onDateSelected,
  });

  final List<HomeroomSemester> semesters;
  final HomeroomSemester? selectedSemester;
  final DateTime weekStart;
  final int selectedDayOfWeek;
  final bool enabled;
  final ValueChanged<int> onSemesterSelected;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD8D8D8)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  key: ValueKey(
                    'homeroom-semester-${selectedSemester?.semesterId}',
                  ),
                  value: selectedSemester?.semesterId,
                  isExpanded: true,
                  hint: const Text('Chưa có học kỳ'),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  onChanged: enabled
                      ? (value) {
                          if (value != null) {
                            onSemesterSelected(value);
                          }
                        }
                      : null,
                  items: semesters
                      .map(
                        (semester) => DropdownMenuItem<int>(
                          value: semester.semesterId,
                          child: Text(
                            semester.semesterName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              key: const ValueKey('homeroom-date-picker'),
              onPressed: enabled && selectedSemester != null
                  ? () => _showDatePicker(context)
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 11),
              ),
              icon: const Icon(Icons.date_range_outlined, size: 18),
              label: Text(
                'Tuần ${_formatDayMonth(weekStart)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final semester = selectedSemester;
    if (semester == null) {
      return;
    }
    final selectedDate = weekStart.add(Duration(days: selectedDayOfWeek - 1));
    final initialDate = _clampDate(
      selectedDate,
      semester.startDate,
      semester.endDate,
    );
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: semester.startDate,
      lastDate: semester.endDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Chọn ngày xem lịch',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (date != null) {
      onDateSelected(date);
    }
  }

  static DateTime _clampDate(
    DateTime date,
    DateTime firstDate,
    DateTime lastDate,
  ) {
    if (date.isBefore(firstDate)) {
      return firstDate;
    }
    if (date.isAfter(lastDate)) {
      return lastDate;
    }
    return date;
  }

  static String _formatDayMonth(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}

class _StudyGroupSelector extends StatelessWidget {
  const _StudyGroupSelector({
    required this.groups,
    required this.selectedId,
    required this.onSelected,
  });

  final List<HomeroomStudyGroup> groups;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _GroupChip(
              label: 'Tất cả',
              selected: selectedId == null,
              onTap: () => onSelected(null),
            ),
            ...groups.map(
              (group) => _GroupChip(
                label: group.studyGroupName,
                selected: selectedId == group.studyGroupId,
                onTap: () => onSelected(group.studyGroupId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  const _GroupChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primaryColor,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? AppTheme.primaryColor : const Color(0xFFDCDCDC),
        ),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.textColor,
          fontWeight: FontWeight.w800,
        ),
        label: Text(label),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        border: Border(
          top: BorderSide(color: Color(0xFFD8D8D8)),
          bottom: BorderSide(color: Color(0xFFD8D8D8)),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 116,
            child: Center(
              child: Text(
                'Thời gian',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: Color(0xFFD8D8D8)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Môn học, hoạt động',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 54,
              color: Color(0xFF999999),
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
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
