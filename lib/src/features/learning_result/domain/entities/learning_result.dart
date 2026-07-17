enum LearningResultPeriod { semester1, semester2, annual }

extension LearningResultPeriodApi on LearningResultPeriod {
  String get apiValue => switch (this) {
    LearningResultPeriod.semester1 => 'SEMESTER_1',
    LearningResultPeriod.semester2 => 'SEMESTER_2',
    LearningResultPeriod.annual => 'ANNUAL',
  };
}

class AcademicYearOption {
  const AcademicYearOption({required this.id, required this.name});

  final int id;
  final String name;
}

class GradeComponentScore {
  const GradeComponentScore({
    required this.componentCode,
    required this.componentName,
    required this.attemptNo,
    required this.score,
  });

  final String componentCode;
  final String componentName;
  final int attemptNo;
  final double score;
}

class SubjectLearningResult {
  const SubjectLearningResult({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.averageScore,
    required this.componentScores,
  });

  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final double? averageScore;
  final List<GradeComponentScore> componentScores;
}

class LearningResultReport {
  const LearningResultReport({
    required this.availableAcademicYears,
    required this.academicYearId,
    required this.academicYearName,
    required this.period,
    required this.finalized,
    required this.subjects,
    this.semesterId,
    this.semesterName,
    this.overallAverage,
    this.academicRank,
    this.conductLabel,
    this.description,
    this.promotionStatus,
  });

  final List<AcademicYearOption> availableAcademicYears;
  final int academicYearId;
  final String academicYearName;
  final LearningResultPeriod period;
  final int? semesterId;
  final String? semesterName;
  final bool finalized;
  final List<SubjectLearningResult> subjects;
  final double? overallAverage;
  final String? academicRank;
  final String? conductLabel;
  final String? description;
  final String? promotionStatus;
}
