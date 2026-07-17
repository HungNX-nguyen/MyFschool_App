import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/timetable_week.dart';

class TimetableShiftHeader extends StatelessWidget {
  const TimetableShiftHeader({required this.shift, super.key});

  final TimetableShift shift;

  @override
  Widget build(BuildContext context) {
    final isMorning = shift == TimetableShift.morning;
    final color = isMorning ? const Color(0xFF08A9D0) : AppTheme.primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFFD8D8D8)),
          right: BorderSide(color: Color(0xFFD8D8D8)),
          bottom: BorderSide(color: Color(0xFFD8D8D8)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isMorning ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
            color: color,
            size: 25,
          ),
          const SizedBox(width: 10),
          Text(
            isMorning ? 'Buổi sáng' : 'Buổi chiều',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class TimetableSlotCard extends StatelessWidget {
  const TimetableSlotCard({
    required this.slot,
    this.teacherView = false,
    this.showStudyGroup = false,
    super.key,
  });

  final TimetableSlot slot;
  final bool teacherView;
  final bool showStudyGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFFD8D8D8)),
          right: BorderSide(color: Color(0xFFD8D8D8)),
          bottom: BorderSide(color: Color(0xFFD8D8D8)),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 116,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tiết ${slot.displaySlotIndex}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, color: const Color(0xFFD8D8D8)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.subjectName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (teacherView) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Lớp: ${slot.className ?? slot.classCode ?? '—'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else if (slot.teacherName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'GV: ${slot.teacherName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    if ((teacherView || showStudyGroup) &&
                        slot.studyGroupName != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Nhóm: ${slot.studyGroupName}',
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (slot.room != null && slot.room!.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Phòng: ${slot.room}',
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) {
      return value;
    }
    final hour = int.tryParse(parts[0]);
    if (hour == null) {
      return value;
    }
    return '${hour}h${parts[1]}';
  }
}

class EmptyShiftMessage extends StatelessWidget {
  const EmptyShiftMessage({this.teacherView = false, super.key});

  final bool teacherView;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          left: BorderSide(color: Color(0xFFD8D8D8)),
          right: BorderSide(color: Color(0xFFD8D8D8)),
          bottom: BorderSide(color: Color(0xFFD8D8D8)),
        ),
      ),
      child: Text(
        teacherView ? 'Không có tiết dạy' : 'Không có tiết học',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF777777)),
      ),
    );
  }
}
