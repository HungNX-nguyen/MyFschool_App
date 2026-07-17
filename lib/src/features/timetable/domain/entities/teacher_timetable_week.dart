import 'timetable_week.dart';

class TeacherTimetableWeek {
  const TeacherTimetableWeek({
    required this.teacherId,
    required this.teacherCode,
    required this.teacherName,
    required this.semesterId,
    required this.semesterName,
    required this.weekStart,
    required this.weekEnd,
    required this.days,
  });

  final int teacherId;
  final String teacherCode;
  final String teacherName;
  final int semesterId;
  final String semesterName;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<TimetableDay> days;
}
