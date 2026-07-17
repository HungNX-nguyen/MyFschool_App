import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/school_event.dart';
import '../controllers/school_event_controller.dart';
import '../widgets/school_event_card.dart';

class SchoolEventPage extends StatefulWidget {
  const SchoolEventPage({required this.controller, super.key});

  final SchoolEventController controller;

  @override
  State<SchoolEventPage> createState() => _SchoolEventPageState();
}

Future<void> showSchoolEventDetails(BuildContext context, SchoolEvent event) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    constraints: const BoxConstraints(maxWidth: 600),
    builder: (context) => SchoolEventDetailSheet(event: event),
  );
}

class _SchoolEventPageState extends State<SchoolEventPage> {
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
  void didUpdateWidget(covariant SchoolEventPage oldWidget) {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textColor,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 72,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Quay lại',
          iconSize: 30,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Sự kiện',
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
            child: Column(
              children: [
                _EventFilters(controller: controller),
                Expanded(child: _buildContent(controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(SchoolEventController controller) {
    if ((controller.status == SchoolEventStatus.idle ||
            controller.status == SchoolEventStatus.loading) &&
        controller.feed == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (controller.status == SchoolEventStatus.error) {
      return _ErrorState(
        message: controller.errorMessage ?? 'Không thể tải danh sách sự kiện.',
        onRetry: controller.retry,
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: controller.retry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
        children: [
          if (controller.isLoading) ...[
            const LinearProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 14),
          ],
          if (controller.hasNoEvents)
            const _EmptyState()
          else
            ...controller.events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SchoolEventCard(
                  event: event,
                  onTap: () => _showEventDetails(event),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showEventDetails(SchoolEvent event) {
    return showSchoolEventDetails(context, event);
  }
}

class _EventFilters extends StatelessWidget {
  const _EventFilters({required this.controller});

  final SchoolEventController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFECECEC))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FilterButton(
                  label: 'Sắp tới',
                  selected:
                      controller.selectedTimeRange ==
                      SchoolEventTimeRange.upcoming,
                  selectedColor: const Color(0xFF246CF2),
                  onTap: () =>
                      controller.selectTimeRange(SchoolEventTimeRange.upcoming),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterButton(
                  label: 'Đã qua',
                  selected:
                      controller.selectedTimeRange == SchoolEventTimeRange.past,
                  selectedColor: const Color(0xFF246CF2),
                  onTap: () =>
                      controller.selectTimeRange(SchoolEventTimeRange.past),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FilterButton(
                  label: 'Tất cả',
                  selected:
                      controller.selectedScope == SchoolEventViewScope.all,
                  selectedColor: AppTheme.primaryColor,
                  compact: true,
                  onTap: () => controller.selectScope(SchoolEventViewScope.all),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterButton(
                  label: _classLabel(controller.feed?.classCode),
                  selected:
                      controller.selectedScope ==
                      SchoolEventViewScope.classEvent,
                  selectedColor: AppTheme.primaryColor,
                  compact: true,
                  onTap: () =>
                      controller.selectScope(SchoolEventViewScope.classEvent),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterButton(
                  label: 'Toàn trường',
                  selected:
                      controller.selectedScope == SchoolEventViewScope.school,
                  selectedColor: AppTheme.primaryColor,
                  compact: true,
                  onTap: () =>
                      controller.selectScope(SchoolEventViewScope.school),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 36 : 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          foregroundColor: selected ? Colors.white : const Color(0xFF777777),
          backgroundColor: selected ? selectedColor : Colors.white,
          side: BorderSide(
            color: selected ? selectedColor : const Color(0xFFE0E0E0),
          ),
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 12 : 15,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class SchoolEventDetailSheet extends StatelessWidget {
  const SchoolEventDetailSheet({required this.event, super.key});

  final SchoolEvent event;

  @override
  Widget build(BuildContext context) {
    final description = event.description?.trim();
    final scopeLabel = event.scope == SchoolEventScope.school
        ? 'Toàn trường'
        : 'Lớp ${event.classCode ?? ''}'.trim();
    final participationLabel =
        event.participationType == SchoolEventParticipationType.required
        ? 'Bắt buộc'
        : 'Tự nguyện';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 2, 22, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            _DetailRow(
              icon: Icons.calendar_month_rounded,
              label: _formatFullDate(event.eventDate),
            ),
            _DetailRow(
              icon: Icons.schedule_rounded,
              label: schoolEventTimeLabel(event),
            ),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: _detailLocation(event.location),
            ),
            _DetailRow(icon: Icons.groups_rounded, label: scopeLabel),
            _DetailRow(
              icon: Icons.assignment_turned_in_outlined,
              label: participationLabel,
            ),
            const SizedBox(height: 14),
            const Text(
              'Nội dung',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              description == null || description.isEmpty
                  ? 'Chưa có nội dung chi tiết.'
                  : description,
              style: const TextStyle(height: 1.45, color: Color(0xFF4F4F4F)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 150),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: Color(0xFFAAAAAA)),
          SizedBox(height: 14),
          Text(
            'Chưa có sự kiện trong mục này.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
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
              Icons.event_busy_rounded,
              size: 62,
              color: Color(0xFF999999),
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
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

String _classLabel(String? classCode) {
  final normalized = classCode?.trim();
  if (normalized == null || normalized.isEmpty) {
    return 'Lớp hiện tại';
  }
  return 'Lớp $normalized';
}

String _detailLocation(String? location) {
  final normalized = location?.trim();
  if (normalized == null || normalized.isEmpty) {
    return 'Chưa cập nhật địa điểm';
  }
  return normalized;
}

String _formatFullDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
