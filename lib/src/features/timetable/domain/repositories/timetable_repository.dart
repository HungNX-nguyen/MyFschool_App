import '../entities/teacher_timetable_week.dart';
import '../entities/timetable_week.dart';

abstract interface class TimetableRepository {
  Future<TimetableWeek> getParentStudentTimetable({
    required int studentId,
    required DateTime weekStart,
    int? semesterId,
  });

  Future<TimetableWeek> getStudentTimetable({
    required DateTime weekStart,
    int? semesterId,
  });

  Future<TeacherTimetableWeek> getTeacherTimetable({
    required DateTime weekStart,
    int? semesterId,
  });
}
