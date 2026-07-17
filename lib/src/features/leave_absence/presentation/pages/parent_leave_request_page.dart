import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../parent/domain/entities/linked_student.dart';
import '../../domain/entities/leave_request.dart';
import '../controllers/parent_leave_request_controller.dart';
import '../widgets/leave_request_card.dart';
import 'create_leave_request_page.dart';

class ParentLeaveRequestPage extends StatefulWidget {
  const ParentLeaveRequestPage({
    required this.controller,
    required this.student,
    super.key,
  });

  final ParentLeaveRequestController controller;
  final LinkedStudent student;

  @override
  State<ParentLeaveRequestPage> createState() => _ParentLeaveRequestPageState();
}

class _ParentLeaveRequestPageState extends State<ParentLeaveRequestPage> {
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
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textColor,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Quay lại',
        ),
        title: const Text(
          'Đơn từ',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: widget.controller.loadRequests,
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final controller = widget.controller;
    if ((controller.status == ParentLeaveRequestStatus.idle ||
            controller.status == ParentLeaveRequestStatus.loading) &&
        controller.requests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 260),
          Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        ],
      );
    }

    if (controller.status == ParentLeaveRequestStatus.error &&
        controller.requests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 180),
          const Icon(
            Icons.description_outlined,
            size: 62,
            color: Color(0xFF999999),
          ),
          const SizedBox(height: 14),
          Text(
            controller.errorMessage ?? 'Không thể tải lịch sử đơn.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Center(
            child: FilledButton.icon(
              onPressed: controller.retry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
      children: [
        _StudentContext(student: widget.student),
        const SizedBox(height: 24),
        const Text(
          'Tạo đơn mới',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.35,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _RequestTypeCard(
              key: const ValueKey('create-leave-request'),
              label: 'Xin nghỉ học',
              icon: Icons.event_available_rounded,
              color: AppTheme.primaryColor,
              onTap: _openCreatePage,
            ),
            const _RequestTypeCard(
              label: 'Đi muộn/Về sớm',
              icon: Icons.more_time_rounded,
              color: Color(0xFF2766D5),
            ),
            const _RequestTypeCard(
              label: 'Xe đưa đón',
              icon: Icons.directions_bus_filled_rounded,
              color: Color(0xFF6EB354),
            ),
            const _RequestTypeCard(
              label: 'Biểu mẫu khác',
              icon: Icons.grid_view_rounded,
              color: Color(0xFF81359C),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Lịch sử đơn',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
            ),
            TextButton(
              onPressed: controller.isLoading ? null : controller.loadRequests,
              child: const Text(
                'Xem tất cả',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        if (controller.isLoading) ...[
          const SizedBox(height: 4),
          const LinearProgressIndicator(color: AppTheme.primaryColor),
        ],
        const SizedBox(height: 10),
        if (controller.requests.isEmpty)
          const _EmptyHistory()
        else
          ...controller.requests.map(
            (request) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: LeaveRequestCard(
                request: request,
                cancelling: controller.processingRequestId == request.id,
                onCancel: request.status == LeaveRequestStatus.pending
                    ? () => _confirmCancel(request)
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openCreatePage() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateLeaveRequestPage(
          controller: widget.controller,
          student: widget.student,
        ),
      ),
    );
    if (created == true && mounted) {
      _showMessage('Gửi đơn xin nghỉ thành công.');
    }
  }

  Future<void> _confirmCancel(LeaveRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn xin nghỉ?'),
        content: const Text(
          'Đơn sẽ chuyển sang trạng thái đã hủy và không thể gửi lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    final success = await widget.controller.cancelLeaveRequest(request.id);
    if (!mounted) {
      return;
    }
    _showMessage(
      success
          ? 'Đã hủy đơn.'
          : widget.controller.actionErrorMessage ?? 'Không thể hủy đơn.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StudentContext extends StatelessWidget {
  const _StudentContext({required this.student});

  final LinkedStudent student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10BE8B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF73D6C9),
            foregroundColor: Colors.white,
            child: Icon(Icons.school_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'MSHS: ${student.studentCode} • Lớp ${student.className ?? 'Chưa xếp lớp'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestTypeCard extends StatelessWidget {
  const _RequestTypeCard({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: enabled ? color : color.withValues(alpha: 0.45),
                size: 34,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: enabled ? AppTheme.textColor : const Color(0xFF777777),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!enabled)
                const Text(
                  'Phát triển sau',
                  style: TextStyle(color: Color(0xFF999999), fontSize: 9),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.description_outlined, size: 50, color: Color(0xFFAAAAAA)),
          SizedBox(height: 10),
          Text(
            'Chưa có đơn xin nghỉ.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
