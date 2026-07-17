import '../../domain/entities/learning_result.dart';

class GradeComponentScoreModel {
  const GradeComponentScoreModel({
    required this.componentCode,
    required this.componentName,
    required this.attemptNo,
    required this.score,
  });

  final String componentCode;
  final String componentName;
  final int attemptNo;
  final double score;

  factory GradeComponentScoreModel.fromJson(Map<String, dynamic> json) {
    return GradeComponentScoreModel(
      componentCode: json['componentCode'] as String,
      componentName: json['componentName'] as String,
      attemptNo: (json['attemptNo'] as num).toInt(),
      score: (json['score'] as num).toDouble(),
    );
  }

  GradeComponentScore toEntity() {
    return GradeComponentScore(
      componentCode: componentCode,
      componentName: componentName,
      attemptNo: attemptNo,
      score: score,
    );
  }
}
