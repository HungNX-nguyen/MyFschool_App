import '../../domain/entities/homeroom_class.dart';

class HomeroomClassRosterModel {
  const HomeroomClassRosterModel({
    required this.classId,
    required this.classCode,
    required this.className,
    required this.academicYearId,
    required this.academicYearName,
    required this.totalStudents,
    required this.students,
  });

  final int classId;
  final String classCode;
  final String className;
  final int academicYearId;
  final String academicYearName;
  final int totalStudents;
  final List<HomeroomStudentModel> students;

  factory HomeroomClassRosterModel.fromJson(Map<String, dynamic> json) {
    final rawStudents = json['students'];
    if (rawStudents is! List<dynamic>) {
      throw const FormatException('Homeroom students must be a list');
    }

    return HomeroomClassRosterModel(
      classId: (json['classId'] as num).toInt(),
      classCode: json['classCode'] as String,
      className: json['className'] as String,
      academicYearId: (json['academicYearId'] as num).toInt(),
      academicYearName: json['academicYearName'] as String,
      totalStudents: (json['totalStudents'] as num).toInt(),
      students: List<HomeroomStudentModel>.unmodifiable(
        rawStudents.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Homeroom student must be an object');
          }
          return HomeroomStudentModel.fromJson(item);
        }),
      ),
    );
  }

  HomeroomClassRoster toEntity() {
    return HomeroomClassRoster(
      classId: classId,
      classCode: classCode,
      className: className,
      academicYearId: academicYearId,
      academicYearName: academicYearName,
      totalStudents: totalStudents,
      students: List<HomeroomStudent>.unmodifiable(
        students.map((student) => student.toEntity()),
      ),
    );
  }
}

class HomeroomStudentModel {
  const HomeroomStudentModel({
    required this.studentId,
    required this.studentCode,
    required this.fullName,
    required this.status,
  });

  final int studentId;
  final String studentCode;
  final String fullName;
  final HomeroomStudentStatus status;

  factory HomeroomStudentModel.fromJson(Map<String, dynamic> json) {
    return HomeroomStudentModel(
      studentId: (json['studentId'] as num).toInt(),
      studentCode: json['studentCode'] as String,
      fullName: json['fullName'] as String,
      status: _parseStudentStatus(json['status']),
    );
  }

  HomeroomStudent toEntity() {
    return HomeroomStudent(
      studentId: studentId,
      studentCode: studentCode,
      fullName: fullName,
      status: status,
    );
  }
}

HomeroomStudentStatus _parseStudentStatus(Object? value) {
  return switch (value) {
    'PENDING_CLASS_ASSIGNMENT' => HomeroomStudentStatus.pendingClassAssignment,
    'ACTIVE' => HomeroomStudentStatus.active,
    'TRANSFERRED_OUT' => HomeroomStudentStatus.transferredOut,
    'GRADUATED' => HomeroomStudentStatus.graduated,
    'INACTIVE' => HomeroomStudentStatus.inactive,
    _ => throw FormatException('Unknown homeroom student status: $value'),
  };
}
