import 'package:flutter/material.dart';

import '../../domain/entities/learning_result.dart';

class LearningResultTable extends StatelessWidget {
  const LearningResultTable({
    required this.subjects,
    required this.period,
    super.key,
  });

  final List<SubjectLearningResult> subjects;
  final LearningResultPeriod period;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD5D5D5)),
      ),
      child: Column(
        children: [
          const _TableHeader(),
          for (var index = 0; index < subjects.length; index++)
            _SubjectRow(
              subject: subjects[index],
              period: period,
              isLast: index == subjects.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      color: const Color(0xFFECECEC),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: Text(
                'Môn học',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: Color(0xFFD5D5D5)),
          Expanded(
            flex: 6,
            child: Center(
              child: Text(
                'Điểm số',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.subject,
    required this.period,
    required this.isLast,
  });

  final SubjectLearningResult subject;
  final LearningResultPeriod period;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isAnnual = period == LearningResultPeriod.annual;

    return IntrinsicHeight(
      child: Container(
        constraints: BoxConstraints(minHeight: isAnnual ? 58 : 88),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFD5D5D5))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subject.subjectName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Container(width: 1, color: const Color(0xFFD5D5D5)),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: isAnnual
                    ? Center(
                        child: Text(
                          _formatScore(subject.averageScore),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : _SemesterScores(subject: subject),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterScores extends StatelessWidget {
  const _SemesterScores({required this.subject});

  final SubjectLearningResult subject;

  @override
  Widget build(BuildContext context) {
    final scores = subject.componentScores
        .map(
          (component) =>
              '${_componentLabel(component)}: '
              '${_formatScore(component.score)}',
        )
        .toList(growable: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (scores.isEmpty)
          const Text('Chưa có điểm thành phần')
        else
          Wrap(
            spacing: 10,
            runSpacing: 5,
            children: scores
                .map(
                  (score) => Text(score, style: const TextStyle(fontSize: 13)),
                )
                .toList(growable: false),
          ),
        const SizedBox(height: 7),
        Text(
          'ĐTB: ${_formatScore(subject.averageScore)}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

String _componentLabel(GradeComponentScore component) {
  return switch (component.componentCode) {
    'DDG_TX' => 'TX${component.attemptNo}',
    'DDG_GK' => 'Giữa kỳ',
    'DDG_CK' => 'Cuối kỳ',
    _ => component.componentName,
  };
}

String _formatScore(double? score) {
  if (score == null) {
    return '—';
  }
  final fixed = score.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}
