import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

class WeekSelector extends StatelessWidget {
  const WeekSelector({
    required this.weekStart,
    required this.selectedDayOfWeek,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onDaySelected,
    super.key,
  });

  final DateTime weekStart;
  final int selectedDayOfWeek;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;
  final ValueChanged<int> onDaySelected;

  static const _dayLabels = <String>['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final selectedDate = weekStart.add(Duration(days: selectedDayOfWeek - 1));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
      child: Column(
        children: [
          Row(
            children: [
              _WeekArrowButton(
                icon: Icons.arrow_left_rounded,
                tooltip: 'Tuần trước',
                onPressed: onPreviousWeek,
              ),
              Expanded(
                child: Text(
                  'Tháng ${selectedDate.month} ${selectedDate.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _WeekArrowButton(
                icon: Icons.arrow_right_rounded,
                tooltip: 'Tuần sau',
                onPressed: onNextWeek,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List<Widget>.generate(7, (index) {
              final dayOfWeek = index + 1;
              final date = weekStart.add(Duration(days: index));
              final isSelected = selectedDayOfWeek == dayOfWeek;
              return Expanded(
                child: Semantics(
                  selected: isSelected,
                  button: true,
                  label: '${_dayLabels[index]}, ngày ${date.day}',
                  child: InkWell(
                    onTap: () => onDaySelected(dayOfWeek),
                    borderRadius: BorderRadius.circular(28),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          Text(
                            _dayLabels[index],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.textColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textColor,
                                fontSize: 17,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _WeekArrowButton extends StatelessWidget {
  const _WeekArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed == null
          ? const Color(0xFFF7F7F7)
          : const Color(0xFFF2F2F2),
      shape: const CircleBorder(),
      elevation: onPressed == null ? 0 : 2,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: 30,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        icon: Icon(
          icon,
          color: onPressed == null
              ? const Color(0xFFBDBDBD)
              : AppTheme.textColor,
        ),
      ),
    );
  }
}
