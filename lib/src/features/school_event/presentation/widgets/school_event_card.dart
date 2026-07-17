import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/school_event.dart';

class SchoolEventCard extends StatelessWidget {
  const SchoolEventCard({required this.event, required this.onTap, super.key});

  final SchoolEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRequired =
        event.participationType == SchoolEventParticipationType.required;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 118),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _DateBadge(date: event.eventDate, highlighted: isRequired),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _InfoLine(
                      icon: Icons.location_on_outlined,
                      text: _locationLabel(event.location),
                    ),
                    const SizedBox(height: 3),
                    _InfoLine(
                      icon: Icons.schedule_rounded,
                      text: _timeLabel(event),
                    ),
                    const SizedBox(height: 6),
                    _ParticipationBadge(type: event.participationType),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB0B0B0),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date, required this.highlighted});

  final DateTime date;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 66,
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFDFA3) : const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.day.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          Text(
            'THÁNG ${date.month}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF777777)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF4F4F4F)),
          ),
        ),
      ],
    );
  }
}

class _ParticipationBadge extends StatelessWidget {
  const _ParticipationBadge({required this.type});

  final SchoolEventParticipationType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      SchoolEventParticipationType.required => (
        'Bắt buộc',
        const Color(0xFFD71920),
      ),
      SchoolEventParticipationType.optional => (
        'Tự nguyện',
        const Color(0xFF777777),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String schoolEventTimeLabel(SchoolEvent event) => _timeLabel(event);

String _timeLabel(SchoolEvent event) {
  if (event.isAllDay) {
    return 'Cả ngày';
  }
  final startTime = _shortTime(event.startTime);
  final endTime = _shortTime(event.endTime);
  if (startTime == null) {
    return 'Chưa cập nhật thời gian';
  }
  return endTime == null ? startTime : '$startTime - $endTime';
}

String _locationLabel(String? location) {
  final normalized = location?.trim();
  if (normalized == null || normalized.isEmpty) {
    return 'Chưa cập nhật địa điểm';
  }
  return normalized;
}

String? _shortTime(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final parts = value.split(':');
  if (parts.length < 2) {
    return value;
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return value;
  }
  return '$hour:${minute.toString().padLeft(2, '0')}';
}
