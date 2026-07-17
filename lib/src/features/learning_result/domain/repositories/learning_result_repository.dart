import '../entities/learning_result.dart';

abstract interface class LearningResultRepository {
  Future<LearningResultReport> getParentStudentResult({
    required int studentId,
    required LearningResultPeriod period,
    int? academicYearId,
  });

  Future<LearningResultReport> getStudentResult({
    required LearningResultPeriod period,
    int? academicYearId,
  });
}
