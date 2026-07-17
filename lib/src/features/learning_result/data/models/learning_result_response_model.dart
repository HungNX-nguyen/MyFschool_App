import '../../domain/entities/learning_result.dart';
import 'academic_year_option_model.dart';
import 'subject_learning_result_model.dart';

class LearningResultResponseModel {
  const LearningResultResponseModel({
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

  final List<AcademicYearOptionModel> availableAcademicYears;
  final int academicYearId;
  final String academicYearName;
  final LearningResultPeriod period;
  final int? semesterId;
  final String? semesterName;
  final bool finalized;
  final List<SubjectLearningResultModel> subjects;
  final double? overallAverage;
  final String? academicRank;
  final String? conductLabel;
  final String? description;
  final String? promotionStatus;

  factory LearningResultResponseModel.fromJson(Map<String, dynamic> json) {
    final yearsJson = json['availableAcademicYears'];
    final subjectsJson = json['subjects'];
    if (yearsJson is! List<dynamic>) {
      throw const FormatException('Available academic years must be a list');
    }
    if (subjectsJson is! List<dynamic>) {
      throw const FormatException('Learning result subjects must be a list');
    }

    return LearningResultResponseModel(
      availableAcademicYears: yearsJson
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Academic year must be an object');
            }
            return AcademicYearOptionModel.fromJson(item);
          })
          .toList(growable: false),
      academicYearId: (json['academicYearId'] as num).toInt(),
      academicYearName: json['academicYearName'] as String,
      period: _parsePeriod(json['period'] as String),
      semesterId: (json['semesterId'] as num?)?.toInt(),
      semesterName: json['semesterName'] as String?,
      finalized: json['finalized'] as bool,
      subjects: subjectsJson
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException(
                'Learning result subject must be an object',
              );
            }
            return SubjectLearningResultModel.fromJson(item);
          })
          .toList(growable: false),
      overallAverage: (json['overallAverage'] as num?)?.toDouble(),
      academicRank: json['academicRank'] as String?,
      conductLabel: json['conductLabel'] as String?,
      description: json['description'] as String?,
      promotionStatus: json['promotionStatus'] as String?,
    );
  }

  LearningResultReport toEntity() {
    return LearningResultReport(
      availableAcademicYears: List<AcademicYearOption>.unmodifiable(
        availableAcademicYears.map((year) => year.toEntity()),
      ),
      academicYearId: academicYearId,
      academicYearName: academicYearName,
      period: period,
      semesterId: semesterId,
      semesterName: semesterName,
      finalized: finalized,
      subjects: List<SubjectLearningResult>.unmodifiable(
        subjects.map((subject) => subject.toEntity()),
      ),
      overallAverage: overallAverage,
      academicRank: academicRank,
      conductLabel: conductLabel,
      description: description,
      promotionStatus: promotionStatus,
    );
  }

  static LearningResultPeriod _parsePeriod(String value) {
    return switch (value) {
      'SEMESTER_1' => LearningResultPeriod.semester1,
      'SEMESTER_2' => LearningResultPeriod.semester2,
      'ANNUAL' => LearningResultPeriod.annual,
      _ => throw FormatException('Unknown learning result period: $value'),
    };
  }
}
