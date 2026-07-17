import '../../domain/entities/homeroom_class.dart';

class HomeroomClassSummaryModel {
  const HomeroomClassSummaryModel({
    required this.classId,
    required this.classCode,
    required this.className,
    required this.academicYearId,
    required this.academicYearName,
    required this.academicYearStartDate,
    required this.academicYearEndDate,
    required this.semesters,
  });

  final int classId;
  final String classCode;
  final String className;
  final int academicYearId;
  final String academicYearName;
  final DateTime academicYearStartDate;
  final DateTime academicYearEndDate;
  final List<HomeroomSemesterModel> semesters;

  factory HomeroomClassSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawSemesters = json['semesters'];
    if (rawSemesters is! List<dynamic>) {
      throw const FormatException('Homeroom semesters must be a list');
    }
    return HomeroomClassSummaryModel(
      classId: (json['classId'] as num).toInt(),
      classCode: json['classCode'] as String,
      className: json['className'] as String,
      academicYearId: (json['academicYearId'] as num).toInt(),
      academicYearName: json['academicYearName'] as String,
      academicYearStartDate: DateTime.parse(
        json['academicYearStartDate'] as String,
      ),
      academicYearEndDate: DateTime.parse(
        json['academicYearEndDate'] as String,
      ),
      semesters: List<HomeroomSemesterModel>.unmodifiable(
        rawSemesters.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Homeroom semester must be an object');
          }
          return HomeroomSemesterModel.fromJson(item);
        }),
      ),
    );
  }

  HomeroomClassSummary toEntity() {
    return HomeroomClassSummary(
      classId: classId,
      classCode: classCode,
      className: className,
      academicYearId: academicYearId,
      academicYearName: academicYearName,
      academicYearStartDate: academicYearStartDate,
      academicYearEndDate: academicYearEndDate,
      semesters: List<HomeroomSemester>.unmodifiable(
        semesters.map((model) => model.toEntity()),
      ),
    );
  }
}

class HomeroomSemesterModel {
  const HomeroomSemesterModel({
    required this.semesterId,
    required this.semesterName,
    required this.semesterIndex,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  final int semesterId;
  final String semesterName;
  final int semesterIndex;
  final DateTime startDate;
  final DateTime endDate;
  final HomeroomSemesterStatus status;

  factory HomeroomSemesterModel.fromJson(Map<String, dynamic> json) {
    return HomeroomSemesterModel(
      semesterId: (json['semesterId'] as num).toInt(),
      semesterName: json['semesterName'] as String,
      semesterIndex: (json['semesterIndex'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: _parseSemesterStatus(json['status']),
    );
  }

  HomeroomSemester toEntity() {
    return HomeroomSemester(
      semesterId: semesterId,
      semesterName: semesterName,
      semesterIndex: semesterIndex,
      startDate: startDate,
      endDate: endDate,
      status: status,
    );
  }
}

HomeroomSemesterStatus _parseSemesterStatus(Object? value) {
  return switch (value) {
    'PLANNED' => HomeroomSemesterStatus.planned,
    'ACTIVE' => HomeroomSemesterStatus.active,
    'CLOSED' => HomeroomSemesterStatus.closed,
    _ => throw FormatException('Unknown homeroom semester status: $value'),
  };
}
