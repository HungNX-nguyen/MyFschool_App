import '../../domain/entities/learning_result.dart';
import 'grade_component_score_model.dart';

class SubjectLearningResultModel {
  const SubjectLearningResultModel({
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
  final List<GradeComponentScoreModel> componentScores;

  factory SubjectLearningResultModel.fromJson(Map<String, dynamic> json) {
    final componentScoresJson = json['componentScores'];
    if (componentScoresJson is! List<dynamic>) {
      throw const FormatException('Component scores must be a list');
    }

    return SubjectLearningResultModel(
      subjectId: (json['subjectId'] as num).toInt(),
      subjectCode: json['subjectCode'] as String,
      subjectName: json['subjectName'] as String,
      averageScore: (json['averageScore'] as num?)?.toDouble(),
      componentScores: componentScoresJson
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Component score must be an object');
            }
            return GradeComponentScoreModel.fromJson(item);
          })
          .toList(growable: false),
    );
  }

  SubjectLearningResult toEntity() {
    return SubjectLearningResult(
      subjectId: subjectId,
      subjectCode: subjectCode,
      subjectName: subjectName,
      averageScore: averageScore,
      componentScores: List<GradeComponentScore>.unmodifiable(
        componentScores.map((score) => score.toEntity()),
      ),
    );
  }
}
