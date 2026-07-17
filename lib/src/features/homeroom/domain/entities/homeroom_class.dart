enum HomeroomStudentStatus {
  pendingClassAssignment,
  active,
  transferredOut,
  graduated,
  inactive,
}

enum HomeroomSemesterStatus { planned, active, closed }

class HomeroomSemester {
  const HomeroomSemester({
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

  bool containsDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    return !normalizedDate.isBefore(normalizedStart) &&
        !normalizedDate.isAfter(normalizedEnd);
  }
}

class HomeroomClassSummary {
  const HomeroomClassSummary({
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
  final List<HomeroomSemester> semesters;
}

class HomeroomClassRoster {
  const HomeroomClassRoster({
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
  final List<HomeroomStudent> students;
}

class HomeroomStudent {
  const HomeroomStudent({
    required this.studentId,
    required this.studentCode,
    required this.fullName,
    required this.status,
  });

  final int studentId;
  final String studentCode;
  final String fullName;
  final HomeroomStudentStatus status;
}
