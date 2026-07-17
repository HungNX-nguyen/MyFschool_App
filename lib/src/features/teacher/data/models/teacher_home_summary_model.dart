import '../../domain/entities/teacher_home_summary.dart';

class TeacherHomeSummaryModel {
  const TeacherHomeSummaryModel({
    required this.teacherId,
    required this.teacherCode,
    required this.teacherName,
    required this.academicYearId,
    required this.academicYearName,
    required this.homeroomClasses,
    required this.teachingAssignments,
  });

  final int teacherId;
  final String teacherCode;
  final String teacherName;
  final int academicYearId;
  final String academicYearName;
  final List<TeacherHomeroomClassModel> homeroomClasses;
  final List<TeacherAssignmentModel> teachingAssignments;

  factory TeacherHomeSummaryModel.fromJson(Map<String, dynamic> json) {
    final homeroomClassesJson = json['homeroomClasses'];
    final teachingAssignmentsJson = json['teachingAssignments'];
    if (homeroomClassesJson is! List<dynamic>) {
      throw const FormatException('Homeroom classes must be a list');
    }
    if (teachingAssignmentsJson is! List<dynamic>) {
      throw const FormatException('Teaching assignments must be a list');
    }

    return TeacherHomeSummaryModel(
      teacherId: (json['teacherId'] as num).toInt(),
      teacherCode: json['teacherCode'] as String,
      teacherName: json['teacherName'] as String,
      academicYearId: (json['academicYearId'] as num).toInt(),
      academicYearName: json['academicYearName'] as String,
      homeroomClasses: homeroomClassesJson
          .map(TeacherHomeroomClassModel.fromJsonObject)
          .toList(growable: false),
      teachingAssignments: teachingAssignmentsJson
          .map(TeacherAssignmentModel.fromJsonObject)
          .toList(growable: false),
    );
  }

  TeacherHomeSummary toEntity() {
    return TeacherHomeSummary(
      teacherId: teacherId,
      teacherCode: teacherCode,
      teacherName: teacherName,
      academicYearId: academicYearId,
      academicYearName: academicYearName,
      homeroomClasses: List<TeacherHomeroomClass>.unmodifiable(
        homeroomClasses.map((item) => item.toEntity()),
      ),
      teachingAssignments: List<TeacherAssignment>.unmodifiable(
        teachingAssignments.map((item) => item.toEntity()),
      ),
    );
  }
}

class TeacherHomeroomClassModel {
  const TeacherHomeroomClassModel({
    required this.classId,
    required this.classCode,
    required this.className,
  });

  final int classId;
  final String classCode;
  final String className;

  factory TeacherHomeroomClassModel.fromJsonObject(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Homeroom class must be an object');
    }
    return TeacherHomeroomClassModel(
      classId: (value['classId'] as num).toInt(),
      classCode: value['classCode'] as String,
      className: value['className'] as String,
    );
  }

  TeacherHomeroomClass toEntity() {
    return TeacherHomeroomClass(
      classId: classId,
      classCode: classCode,
      className: className,
    );
  }
}

class TeacherAssignmentModel {
  const TeacherAssignmentModel({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.classId,
    required this.classCode,
    required this.className,
  });

  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final int classId;
  final String classCode;
  final String className;

  factory TeacherAssignmentModel.fromJsonObject(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Teaching assignment must be an object');
    }
    return TeacherAssignmentModel(
      subjectId: (value['subjectId'] as num).toInt(),
      subjectCode: value['subjectCode'] as String,
      subjectName: value['subjectName'] as String,
      classId: (value['classId'] as num).toInt(),
      classCode: value['classCode'] as String,
      className: value['className'] as String,
    );
  }

  TeacherAssignment toEntity() {
    return TeacherAssignment(
      subjectId: subjectId,
      subjectCode: subjectCode,
      subjectName: subjectName,
      classId: classId,
      classCode: classCode,
      className: className,
    );
  }
}
