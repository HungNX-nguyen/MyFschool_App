import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/learning_result/domain/entities/learning_result.dart';
import 'package:myfschoolse1913/src/features/learning_result/domain/repositories/learning_result_repository.dart';
import 'package:myfschoolse1913/src/features/learning_result/presentation/controllers/learning_result_controller.dart';
import 'package:myfschoolse1913/src/features/learning_result/presentation/pages/learning_result_page.dart';

void main() {
  testWidgets('hiển thị kết quả năm và điểm thành phần kỳ I trên Pixel 6 Pro', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeLearningResultRepository(<LearningResultReport>[
      _annualReport(),
      _semesterReport(),
    ]);
    final controller = LearningResultController(
      repository,
      audience: LearningResultAudience.student,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LearningResultPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kết quả học tập'), findsOneWidget);
    expect(find.text('2025 - 2026'), findsOneWidget);
    expect(find.text('Ngữ văn'), findsOneWidget);
    expect(find.text('8.25'), findsNWidgets(2));
    expect(find.text('Khá'), findsOneWidget);
    expect(find.text('Lên lớp'), findsOneWidget);
    expect(find.text('Nhận xét của giáo viên'), findsOneWidget);
    expect(
      find.text('Em có ý thức học tập tốt và tích cực tham gia hoạt động lớp.'),
      findsOneWidget,
    );
    expect(find.textContaining('TX1:'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Kỳ I'));
    await tester.pumpAndSettle();

    expect(find.text('TX1: 8'), findsOneWidget);
    expect(find.text('TX2: 7.5'), findsOneWidget);
    expect(find.text('Giữa kỳ: 8.5'), findsOneWidget);
    expect(find.text('Cuối kỳ: 9'), findsOneWidget);
    expect(find.text('ĐTB: 8.35'), findsOneWidget);
    expect(find.text('Lên lớp'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

LearningResultReport _annualReport() {
  return const LearningResultReport(
    availableAcademicYears: <AcademicYearOption>[
      AcademicYearOption(id: 2, name: '2025 - 2026'),
      AcademicYearOption(id: 1, name: '2024 - 2025'),
    ],
    academicYearId: 2,
    academicYearName: '2025 - 2026',
    period: LearningResultPeriod.annual,
    finalized: true,
    subjects: <SubjectLearningResult>[
      SubjectLearningResult(
        subjectId: 1,
        subjectCode: 'NGU_VAN',
        subjectName: 'Ngữ văn',
        averageScore: 8.25,
        componentScores: <GradeComponentScore>[],
      ),
    ],
    overallAverage: 8.25,
    academicRank: 'Khá',
    conductLabel: 'Tốt',
    description: 'Em có ý thức học tập tốt và tích cực tham gia hoạt động lớp.',
    promotionStatus: 'PROMOTED',
  );
}

LearningResultReport _semesterReport() {
  return const LearningResultReport(
    availableAcademicYears: <AcademicYearOption>[
      AcademicYearOption(id: 2, name: '2025 - 2026'),
      AcademicYearOption(id: 1, name: '2024 - 2025'),
    ],
    academicYearId: 2,
    academicYearName: '2025 - 2026',
    period: LearningResultPeriod.semester1,
    semesterId: 3,
    semesterName: 'Học kỳ I',
    finalized: true,
    subjects: <SubjectLearningResult>[
      SubjectLearningResult(
        subjectId: 1,
        subjectCode: 'NGU_VAN',
        subjectName: 'Ngữ văn',
        averageScore: 8.35,
        componentScores: <GradeComponentScore>[
          GradeComponentScore(
            componentCode: 'DDG_TX',
            componentName: 'Đánh giá thường xuyên',
            attemptNo: 1,
            score: 8,
          ),
          GradeComponentScore(
            componentCode: 'DDG_TX',
            componentName: 'Đánh giá thường xuyên',
            attemptNo: 2,
            score: 7.5,
          ),
          GradeComponentScore(
            componentCode: 'DDG_GK',
            componentName: 'Đánh giá giữa kỳ',
            attemptNo: 1,
            score: 8.5,
          ),
          GradeComponentScore(
            componentCode: 'DDG_CK',
            componentName: 'Đánh giá cuối kỳ',
            attemptNo: 1,
            score: 9,
          ),
        ],
      ),
    ],
    overallAverage: 8.35,
    academicRank: 'Khá',
  );
}

class _FakeLearningResultRepository implements LearningResultRepository {
  _FakeLearningResultRepository(this._responses);

  final List<LearningResultReport> _responses;

  @override
  Future<LearningResultReport> getParentStudentResult({
    required int studentId,
    required LearningResultPeriod period,
    int? academicYearId,
  }) async {
    return _responses.removeAt(0);
  }

  @override
  Future<LearningResultReport> getStudentResult({
    required LearningResultPeriod period,
    int? academicYearId,
  }) async {
    return _responses.removeAt(0);
  }
}
