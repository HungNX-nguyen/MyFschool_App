import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/leave_request.dart';
import 'leave_request_card.dart';

class TeacherLeaveRequestCard extends StatelessWidget {
  const TeacherLeaveRequestCard({
    required this.request,
    this.onApprove,
    this.onReject,
    this.processing = false,
    super.key,
  });

  final LeaveRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool processing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFFFEEE5),
                foregroundColor: AppTheme.primaryColor,
                child: Icon(Icons.school_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'MSHS: ${request.studentCode} • ${request.classCode}',
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
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(height: 1),
          ),
          _DetailRow(label: 'Phụ huynh', value: request.parentName),
          const SizedBox(height: 7),
          _DetailRow(label: 'Thời gian', value: _dateRange(request)),
          const SizedBox(height: 7),
          _DetailRow(label: 'Lý do', value: request.reason),
          if (request.reviewNote != null &&
              request.reviewNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            _DetailRow(label: 'Phản hồi', value: request.reviewNote!),
          ],
          if (request.status == LeaveRequestStatus.pending &&
              onApprove != null &&
              onReject != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: ValueKey('reject-leave-request-${request.id}'),
                    onPressed: processing ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text(
                      'Từ chối',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    key: ValueKey('approve-leave-request-${request.id}'),
                    onPressed: processing ? null : onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF33A852),
                    ),
                    icon: processing
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: const Text(
                      'Duyệt',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

String _dateRange(LeaveRequest request) {
  final from = _formatDate(request.fromDate);
  final to = _formatDate(request.toDate);
  return from == to ? from : '$from - $to';
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
