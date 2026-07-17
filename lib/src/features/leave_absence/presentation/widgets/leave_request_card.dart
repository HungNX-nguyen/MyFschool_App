import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/leave_request.dart';

class LeaveRequestCard extends StatelessWidget {
  const LeaveRequestCard({
    required this.request,
    this.onCancel,
    this.cancelling = false,
    super.key,
  });

  final LeaveRequest request;
  final VoidCallback? onCancel;
  final bool cancelling;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEE5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: AppTheme.primaryColor,
                  size: 31,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đơn xin nghỉ học',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gửi lúc ${_formatDateTime(request.createdAt)}',
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              LeaveRequestStatusChip(status: request.status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Thời gian: ',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: _formatDateRange(request)),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Chi tiết: ',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: request.reason),
              ],
            ),
          ),
          if (request.reviewNote != null &&
              request.reviewNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Phản hồi: ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: request.reviewNote),
                ],
              ),
            ),
          ],
          if (request.status == LeaveRequestStatus.pending &&
              onCancel != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                key: ValueKey('cancel-leave-request-${request.id}'),
                onPressed: cancelling ? null : onCancel,
                icon: cancelling
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.close_rounded),
                label: const Text('Hủy đơn'),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LeaveRequestStatusChip extends StatelessWidget {
  const LeaveRequestStatusChip({required this.status, super.key});

  final LeaveRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, foreground, background) = switch (status) {
      LeaveRequestStatus.pending => (
        'Chờ duyệt',
        const Color(0xFF9A5200),
        const Color(0xFFFFD49C),
      ),
      LeaveRequestStatus.approved => (
        'Đã duyệt',
        const Color(0xFF2E6E20),
        const Color(0xFFCBE9B8),
      ),
      LeaveRequestStatus.rejected => (
        'Từ chối',
        const Color(0xFF9E2630),
        const Color(0xFFFFCDD2),
      ),
      LeaveRequestStatus.cancelled => (
        'Đã hủy',
        const Color(0xFF5F6368),
        const Color(0xFFE5E5E5),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _formatDateRange(LeaveRequest request) {
  if (_sameDate(request.fromDate, request.toDate)) {
    return _formatDate(request.fromDate);
  }
  return '${_formatDate(request.fromDate)} - ${_formatDate(request.toDate)}';
}

String _formatDate(DateTime date) {
  return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
}

String _formatDateTime(DateTime dateTime) {
  return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}'
      ' - ${_formatDate(dateTime)}';
}

bool _sameDate(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
