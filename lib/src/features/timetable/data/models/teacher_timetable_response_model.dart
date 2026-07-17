import '../../domain/entities/teacher_timetable_week.dart';
import '../../domain/entities/timetable_week.dart';
import 'timetable_day_model.dart';

class TeacherTimetableResponseModel {
  const TeacherTimetableResponseModel({
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
  final List<TimetableDayModel> days;

  factory TeacherTimetableResponseModel.fromJson(Map<String, dynamic> json) {
    final daysJson = json['days'];
    if (daysJson is! List<dynamic>) {
      throw const FormatException('Teacher timetable days must be a list');
    }

    return TeacherTimetableResponseModel(
      teacherId: (json['teacherId'] as num).toInt(),
      teacherCode: json['teacherCode'] as String,
      teacherName: json['teacherName'] as String,
      semesterId: (json['semesterId'] as num).toInt(),
      semesterName: json['semesterName'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      days: daysJson
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException(
                'Teacher timetable day must be an object',
              );
            }
            return TimetableDayModel.fromJson(item);
          })
          .toList(growable: false),
    );
  }

  TeacherTimetableWeek toEntity() {
    return TeacherTimetableWeek(
      teacherId: teacherId,
      teacherCode: teacherCode,
      teacherName: teacherName,
      semesterId: semesterId,
      semesterName: semesterName,
      weekStart: weekStart,
      weekEnd: weekEnd,
      days: List<TimetableDay>.unmodifiable(days.map((day) => day.toEntity())),
    );
  }
}
