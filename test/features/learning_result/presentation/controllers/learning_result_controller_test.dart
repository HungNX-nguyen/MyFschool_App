import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/core/network/api_exception.dart';
import 'package:myfschoolse1913/src/features/learning_result/domain/entities/learning_result.dart';
import 'package:myfschoolse1913/src/features/learning_result/domain/repositories/learning_result_repository.dart';
import 'package:myfschoolse1913/src/features/learning_result/presentation/controllers/learning_result_controller.dart';

void main() {
  group('LearningResultController', () {
    test('Parent tải kết quả đúng học sinh liên kết', () async {
      final repository = _FakeLearningResultRepository(
        responses: <LearningResultReport>[
          _report(
            academicYearId: 2,
            academicYearName: '2025 - 2026',
            finalized: true,
          ),
        ],
      );
      final controller = LearningResultController(
        repository,
        audience: LearningResultAudience.parent,
        studentId: 37,
      );

      await controller.loadInitial();

      expect(controller.status, LearningResultStatus.success);
      expect(controller.selectedPeriod, LearningResultPeriod.annual);
      expect(controller.selectedAcademicYearId, 2);
      expect(repository.parentStudentIds, <int>[37]);
      expect(repository.studentCallCount, 0);
    });

    test('Student tự chọn năm gần nhất đã có kết quả', () async {
      final repository = _FakeLearningResultRepository(
        responses: <LearningResultReport>[
          _report(
            academicYearId: 3,
            academicYearName: '2026 - 2027',
            finalized: false,
          ),
          _report(
            academicYearId: 2,
            academicYearName: '2025 - 2026',
            finalized: true,
          ),
        ],
      );
      final controller = LearningResultController(
        repository,
        audience: LearningResultAudience.student,
      );

      await controller.loadInitial();

      expect(controller.status, LearningResultStatus.success);
      expect(controller.selectedAcademicYearId, 2);
      expect(repository.requestedAcademicYearIds, <int?>[null, 2]);
      expect(repository.studentCallCount, 2);
    });

    test('đổi kỳ giữ nguyên năm học đang chọn', () async {
      final repository = _FakeLearningResultRepository(
        responses: <LearningResultReport>[
          _report(
            academicYearId: 2,
            academicYearName: '2025 - 2026',
            finalized: true,
          ),
          _report(
            academicYearId: 2,
            academicYearName: '2025 - 2026',
            finalized: true,
            period: LearningResultPeriod.semester1,
          ),
        ],
      );
      final controller = LearningResultController(
        repository,
        audience: LearningResultAudience.student,
      );

      await controller.loadInitial();
      await controller.selectPeriod(LearningResultPeriod.semester1);

      expect(controller.selectedPeriod, LearningResultPeriod.semester1);
      expect(repository.requestedAcademicYearIds, <int?>[null, 2]);
      expect(repository.requestedPeriods, <LearningResultPeriod>[
        LearningResultPeriod.annual,
        LearningResultPeriod.semester1,
      ]);
    });

    test('hiển thị chưa có dữ liệu khi API chưa có dữ liệu năm học', () async {
      final controller = LearningResultController(
        const _ErrorLearningResultRepository(),
        audience: LearningResultAudience.student,
      );

      await controller.loadInitial();

      expect(controller.status, LearningResultStatus.error);
      expect(controller.errorMessage, 'Chưa có dữ liệu năm học.');
    });
  });
}

LearningResultReport _report({
  required int academicYearId,
  required String academicYearName,
  required bool finalized,
  LearningResultPeriod period = LearningResultPeriod.annual,
}) {
  return LearningResultReport(
    availableAcademicYears: const <AcademicYearOption>[
      AcademicYearOption(id: 2, name: '2025 - 2026'),
      AcademicYearOption(id: 1, name: '2024 - 2025'),
    ],
    academicYearId: academicYearId,
    academicYearName: academicYearName,
    period: period,
    finalized: finalized,
    subjects: const <SubjectLearningResult>[],
  );
}

class _FakeLearningResultRepository implements LearningResultRepository {
  _FakeLearningResultRepository({required List<LearningResultReport> responses})
    : _responses = List<LearningResultReport>.of(responses);

  final List<LearningResultReport> _responses;
  final List<int> parentStudentIds = <int>[];
  final List<int?> requestedAcademicYearIds = <int?>[];
  final List<LearningResultPeriod> requestedPeriods = <LearningResultPeriod>[];
  int studentCallCount = 0;

  @override
  Future<LearningResultReport> getParentStudentResult({
    required int studentId,
    required LearningResultPeriod period,
    int? academicYearId,
  }) async {
    parentStudentIds.add(studentId);
    _trackRequest(academicYearId, period);
    return _responses.removeAt(0);
  }

  @override
  Future<LearningResultReport> getStudentResult({
    required LearningResultPeriod period,
    int? academicYearId,
  }) async {
    studentCallCount++;
    _trackRequest(academicYearId, period);
    return _responses.removeAt(0);
  }

  void _trackRequest(int? academicYearId, LearningResultPeriod period) {
    requestedAcademicYearIds.add(academicYearId);
    requestedPeriods.add(period);
  }
}

class _ErrorLearningResultRepository implements LearningResultRepository {
  const _ErrorLearningResultRepository();

  static const _error = ApiException(
    code: 'INTERNAL_SERVER_ERROR',
    message: 'Đã xảy ra lỗi hệ thống',
  );

  @override
  Future<LearningResultReport> getParentStudentResult({
    required int studentId,
    required LearningResultPeriod period,
    int? academicYearId,
  }) {
    throw _error;
  }

  @override
  Future<LearningResultReport> getStudentResult({
    required LearningResultPeriod period,
    int? academicYearId,
  }) {
    throw _error;
  }
}
