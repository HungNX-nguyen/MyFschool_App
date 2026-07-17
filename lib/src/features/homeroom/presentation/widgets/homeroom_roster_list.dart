import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/homeroom_class.dart';

class HomeroomRosterList extends StatelessWidget {
  const HomeroomRosterList({
    required this.roster,
    required this.onRefresh,
    super.key,
  });

  final HomeroomClassRoster roster;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: onRefresh,
      child: ListView(
        key: const ValueKey('homeroom-roster-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _RosterSummary(totalStudents: roster.totalStudents),
          const SizedBox(height: 14),
          if (roster.students.isEmpty)
            const _EmptyRoster()
          else
            ...List<Widget>.generate(roster.students.length, (index) {
              final student = roster.students[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StudentRow(index: index + 1, student: student),
              );
            }),
        ],
      ),
    );
  }
}

class _RosterSummary extends StatelessWidget {
  const _RosterSummary({required this.totalStudents});

  final int totalStudents;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3EC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD5BF)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            child: Icon(Icons.groups_2_rounded),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Danh sách học sinh',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            'Sĩ số: $totalStudents',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.index, required this.student});

  final int index;
  final HomeroomStudent student;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('homeroom-student-${student.studentId}'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: const Color(0xFFEAF4FF),
            foregroundColor: const Color(0xFF1769AA),
            child: Text(
              '$index',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MSHS: ${student.studentCode}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF686868),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(status: student.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final HomeroomStudentStatus status;

  @override
  Widget build(BuildContext context) {
    final active = status == HomeroomStudentStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE7F8EF) : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: active ? const Color(0xFF138A4A) : const Color(0xFF666666),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _statusLabel(HomeroomStudentStatus value) {
    return switch (value) {
      HomeroomStudentStatus.pendingClassAssignment => 'Chờ xếp lớp',
      HomeroomStudentStatus.active => 'Đang học',
      HomeroomStudentStatus.transferredOut => 'Đã chuyển',
      HomeroomStudentStatus.graduated => 'Tốt nghiệp',
      HomeroomStudentStatus.inactive => 'Ngừng học',
    };
  }
}

class _EmptyRoster extends StatelessWidget {
  const _EmptyRoster();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 90),
      child: Column(
        children: [
          Icon(Icons.person_search_rounded, size: 62, color: Color(0xFFAAAAAA)),
          SizedBox(height: 14),
          Text(
            'Lớp chưa có học sinh.',
            style: TextStyle(color: Color(0xFF666666), fontSize: 15),
          ),
        ],
      ),
    );
  }
}
