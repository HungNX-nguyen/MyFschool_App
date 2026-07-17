import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/homeroom_class.dart';
import '../../domain/entities/leave_request.dart';
import '../controllers/teacher_leave_request_controller.dart';
import '../widgets/teacher_leave_request_card.dart';

class TeacherLeaveRequestPage extends StatefulWidget {
  const TeacherLeaveRequestPage({required this.controller, super.key});

  final TeacherLeaveRequestController controller;

  @override
  State<TeacherLeaveRequestPage> createState() =>
      _TeacherLeaveRequestPageState();
}

class _TeacherLeaveRequestPageState extends State<TeacherLeaveRequestPage> {
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
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: AppTheme.primaryColor,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Quay lại',
        ),
        title: const Text(
          'Xử lý đơn',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: widget.controller.retry,
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final controller = widget.controller;
    if ((controller.status == TeacherLeaveRequestPageStatus.idle ||
            controller.status == TeacherLeaveRequestPageStatus.loading) &&
        controller.classes.isEmpty) {
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

    if (controller.status == TeacherLeaveRequestPageStatus.error &&
        controller.classes.isEmpty) {
      return _ErrorContent(
        message: controller.errorMessage ?? 'Không thể tải danh sách đơn.',
        onRetry: controller.retry,
      );
    }

    if (controller.classes.isEmpty) {
      return const _NoHomeroomClass();
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      children: [
        _ClassSelector(
          classes: controller.classes,
          selectedClass: controller.selectedClass!,
          onSelected: controller.selectClass,
        ),
        const SizedBox(height: 18),
        _StatusSelector(
          selectedStatus: controller.selectedStatus,
          onSelected: controller.selectStatus,
        ),
        if (controller.isLoading) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(color: AppTheme.primaryColor),
        ],
        const SizedBox(height: 18),
        if (controller.status == TeacherLeaveRequestPageStatus.error)
          _InlineError(
            message: controller.errorMessage ?? 'Không thể tải danh sách đơn.',
            onRetry: controller.retry,
          )
        else if (controller.requests.isEmpty)
          _EmptyRequestList(status: controller.selectedStatus)
        else
          ...controller.requests.map(
            (request) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TeacherLeaveRequestCard(
                request: request,
                processing: controller.processingRequestId == request.id,
                onApprove: request.status == LeaveRequestStatus.pending
                    ? () => _review(request, LeaveRequestDecision.approved)
                    : null,
                onReject: request.status == LeaveRequestStatus.pending
                    ? () => _review(request, LeaveRequestDecision.rejected)
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _review(
    LeaveRequest request,
    LeaveRequestDecision decision,
  ) async {
    final result = await showDialog<_ReviewDialogResult>(
      context: context,
      builder: (_) =>
          _ReviewDialog(studentName: request.studentName, decision: decision),
    );
    if (result == null || !mounted) {
      return;
    }

    final success = await widget.controller.reviewLeaveRequest(
      leaveRequestId: request.id,
      decision: decision,
      reviewNote: result.note,
    );
    if (!mounted) {
      return;
    }
    final successMessage = decision == LeaveRequestDecision.approved
        ? 'Đã duyệt đơn xin nghỉ.'
        : 'Đã từ chối đơn xin nghỉ.';
    _showMessage(
      success
          ? successMessage
          : widget.controller.actionErrorMessage ?? 'Không thể xử lý đơn.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ClassSelector extends StatelessWidget {
  const _ClassSelector({
    required this.classes,
    required this.selectedClass,
    required this.onSelected,
  });

  final List<HomeroomClass> classes;
  final HomeroomClass selectedClass;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFFFEEE5),
            foregroundColor: AppTheme.primaryColor,
            child: Icon(Icons.groups_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lớp chủ nhiệm',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 11),
                ),
                DropdownButton<int>(
                  key: const ValueKey('homeroom-class-selector'),
                  value: selectedClass.classId,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({
    required this.selectedStatus,
    required this.onSelected,
  });

  final LeaveRequestStatus selectedStatus;
  final ValueChanged<LeaveRequestStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: LeaveRequestStatus.values
            .map(
              (status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: ValueKey('teacher-status-${status.apiValue}'),
                  selected: selectedStatus == status,
                  onSelected: (_) => onSelected(status),
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: selectedStatus == status
                        ? Colors.white
                        : AppTheme.textColor,
                    fontWeight: FontWeight.w800,
                  ),
                  label: Text(_statusLabel(status)),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({required this.studentName, required this.decision});

  final String studentName;
  final LeaveRequestDecision decision;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _noteController = TextEditingController();
  String? _errorText;

  bool get _rejecting => widget.decision == LeaveRequestDecision.rejected;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_rejecting ? 'Từ chối đơn' : 'Duyệt đơn'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _rejecting
                  ? 'Nhập lý do từ chối đơn của ${widget.studentName}.'
                  : 'Xác nhận cho ${widget.studentName} nghỉ có phép.',
            ),
            const SizedBox(height: 14),
            TextField(
              key: const ValueKey('teacher-review-note'),
              controller: _noteController,
              minLines: 3,
              maxLines: 5,
              maxLength: 2000,
              decoration: InputDecoration(
                labelText: _rejecting
                    ? 'Lý do từ chối'
                    : 'Ghi chú (không bắt buộc)',
                errorText: _errorText,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        FilledButton(
          key: const ValueKey('confirm-teacher-review'),
          onPressed: _confirm,
          style: FilledButton.styleFrom(
            backgroundColor: _rejecting
                ? Colors.redAccent
                : const Color(0xFF33A852),
          ),
          child: Text(_rejecting ? 'Từ chối' : 'Duyệt đơn'),
        ),
      ],
    );
  }

  void _confirm() {
    final note = _noteController.text.trim();
    if (_rejecting && note.isEmpty) {
      setState(() {
        _errorText = 'Vui lòng nhập lý do từ chối';
      });
      return;
    }
    Navigator.of(context).pop(_ReviewDialogResult(note.isEmpty ? null : note));
  }
}

class _ReviewDialogResult {
  const _ReviewDialogResult(this.note);

  final String? note;
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 180),
        const Icon(
          Icons.mark_email_unread_outlined,
          size: 62,
          color: Color(0xFF999999),
        ),
        const SizedBox(height: 14),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ),
      ],
    );
  }
}

class _NoHomeroomClass extends StatelessWidget {
  const _NoHomeroomClass();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(28),
      children: const [
        SizedBox(height: 190),
        Icon(Icons.groups_outlined, size: 64, color: Color(0xFF999999)),
        SizedBox(height: 14),
        Text(
          'Bạn chưa được phân công chủ nhiệm lớp trong năm học hiện tại.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _EmptyRequestList extends StatelessWidget {
  const _EmptyRequestList({required this.status});

  final LeaveRequestStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: 54,
            color: Color(0xFF999999),
          ),
          const SizedBox(height: 12),
          Text(
            'Không có đơn ở trạng thái ${_statusLabel(status).toLowerCase()}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(LeaveRequestStatus status) {
  return switch (status) {
    LeaveRequestStatus.pending => 'Chờ duyệt',
    LeaveRequestStatus.approved => 'Đã duyệt',
    LeaveRequestStatus.rejected => 'Từ chối',
    LeaveRequestStatus.cancelled => 'Đã hủy',
  };
}
