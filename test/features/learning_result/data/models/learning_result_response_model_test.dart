import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/learning_result/data/models/learning_result_response_model.dart';

void main() {
  test('map description từ response sang learning result report', () {
    final model = LearningResultResponseModel.fromJson(<String, dynamic>{
      'availableAcademicYears': <Map<String, dynamic>>[
        <String, dynamic>{'id': 3, 'name': '2026 - 2027'},
      ],
      'academicYearId': 3,
      'academicYearName': '2026 - 2027',
      'period': 'SEMESTER_1',
      'semesterId': 5,
      'semesterName': 'Học kỳ I',
      'finalized': true,
      'subjects': <Map<String, dynamic>>[],
      'overallAverage': 7.82,
      'academicRank': 'Khá',
      'conductLabel': 'Tốt',
      'description':
          'Em có ý thức học tập tốt và tích cực tham gia hoạt động lớp.',
      'promotionStatus': null,
    });

    expect(
      model.toEntity().description,
      'Em có ý thức học tập tốt và tích cực tham gia hoạt động lớp.',
    );
  });
}
