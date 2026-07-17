class TeacherHomeSummary {
  const TeacherHomeSummary({
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
  final List<TeacherHomeroomClass> homeroomClasses;
  final List<TeacherAssignment> teachingAssignments;
}

class TeacherHomeroomClass {
  const TeacherHomeroomClass({
    required this.classId,
    required this.classCode,
    required this.className,
  });

  final int classId;
  final String classCode;
  final String className;
}

class TeacherAssignment {
  const TeacherAssignment({
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
}
