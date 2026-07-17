import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/learning_result.dart';
import '../controllers/learning_result_controller.dart';
import '../widgets/learning_result_table.dart';

class LearningResultPage extends StatefulWidget {
  const LearningResultPage({required this.controller, super.key});

  final LearningResultController controller;

  @override
  State<LearningResultPage> createState() => _LearningResultPageState();
}

class _LearningResultPageState extends State<LearningResultPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
    _scheduleInitialLoad();
  }

  @override
  void didUpdateWidget(covariant LearningResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
    _scheduleInitialLoad();
  }

  void _scheduleInitialLoad() {
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
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 68,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Quay lại',
          iconSize: 32,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Kết quả học tập',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                _AcademicYearSelector(controller: controller),
                _PeriodSelector(controller: controller),
                Expanded(child: _buildContent(controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LearningResultController controller) {
    if (controller.status == LearningResultStatus.idle ||
        controller.status == LearningResultStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (controller.status == LearningResultStatus.error) {
      return _ErrorState(
        message: controller.errorMessage ?? 'Không thể tải kết quả học tập.',
        onRetry: controller.retry,
      );
    }

    final report = controller.report;
    if (report == null || !report.finalized || report.subjects.isEmpty) {
      return const _EmptyState();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        LearningResultTable(subjects: report.subjects, period: report.period),
        const SizedBox(height: 18),
        _SummaryCard(report: report),
      ],
    );
  }
}

class _AcademicYearSelector extends StatelessWidget {
  const _AcademicYearSelector({required this.controller});

  final LearningResultController controller;

  @override
  Widget build(BuildContext context) {
    final report = controller.report;
    final yearName = report?.academicYearName ?? 'Năm học';

    return SizedBox(
      height: 58,
      child: Row(
        children: [
          IconButton(
            key: const ValueKey('older-academic-year'),
            onPressed: controller.canSelectOlderAcademicYear
                ? controller.selectOlderAcademicYear
                : null,
            tooltip: 'Năm học trước',
            icon: const Icon(Icons.arrow_left_rounded, size: 36),
          ),
          Expanded(
            child: Text(
              yearName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            key: const ValueKey('newer-academic-year'),
            onPressed: controller.canSelectNewerAcademicYear
                ? controller.selectNewerAcademicYear
                : null,
            tooltip: 'Năm học sau',
            icon: const Icon(Icons.arrow_right_rounded, size: 36),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.controller});

  final LearningResultController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: _PeriodButton(
              label: 'Kỳ I',
              selected:
                  controller.selectedPeriod == LearningResultPeriod.semester1,
              onTap: () =>
                  controller.selectPeriod(LearningResultPeriod.semester1),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _PeriodButton(
              label: 'Kỳ II',
              selected:
                  controller.selectedPeriod == LearningResultPeriod.semester2,
              onTap: () =>
                  controller.selectPeriod(LearningResultPeriod.semester2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _PeriodButton(
              label: 'Cuối năm',
              selected:
                  controller.selectedPeriod == LearningResultPeriod.annual,
              onTap: () => controller.selectPeriod(LearningResultPeriod.annual),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          backgroundColor: selected ? AppTheme.primaryColor : Colors.white,
          foregroundColor: selected ? Colors.white : AppTheme.textColor,
          side: const BorderSide(color: AppTheme.primaryColor),
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.report});

  final LearningResultReport report;

  @override
  Widget build(BuildContext context) {
    final description = report.description?.trim();
    final rows = <({String label, String value})>[
      (
        label: 'Điểm trung bình',
        value: _formatSummaryScore(report.overallAverage),
      ),
      if (report.conductLabel != null)
        (label: 'Hạnh kiểm', value: report.conductLabel!),
      if (report.academicRank != null)
        (label: 'Xếp loại', value: report.academicRank!),
      if (report.period == LearningResultPeriod.annual &&
          report.promotionStatus != null)
        (label: 'Kết quả', value: _promotionLabel(report.promotionStatus!)),
      if (description != null && description.isNotEmpty)
        (label: 'Nhận xét của giáo viên', value: description),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F3),
        border: Border.all(color: const Color(0xFFFFC7B2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: List<Widget>.generate(
          rows.length,
          (index) => _SummaryRow(
            label: rows[index].label,
            value: rows[index].value,
            isLast: index == rows.length - 1,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFFFD8C9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: true,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, size: 60, color: Color(0xFF999999)),
            SizedBox(height: 14),
            Text(
              'Chưa có kết quả học tập cho thời gian này.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
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
              Icons.error_outline_rounded,
              size: 58,
              color: Color(0xFF999999),
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatSummaryScore(double? score) {
  if (score == null) {
    return '—';
  }
  final fixed = score.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

String _promotionLabel(String value) {
  return switch (value) {
    'PROMOTED' => 'Lên lớp',
    'RETAINED' => 'Lưu ban',
    _ => value,
  };
}
