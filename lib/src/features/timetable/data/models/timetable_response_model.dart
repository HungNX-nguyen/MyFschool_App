import '../../domain/entities/timetable_week.dart';
import 'timetable_day_model.dart';

class TimetableResponseModel {
  const TimetableResponseModel({
    required this.classId,
    required this.classCode,
    required this.className,
    required this.semesterId,
    required this.semesterName,
    required this.weekStart,
    required this.weekEnd,
    required this.days,
  });

  final int classId;
  final String classCode;
  final String className;
  final int semesterId;
  final String semesterName;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<TimetableDayModel> days;

  factory TimetableResponseModel.fromJson(Map<String, dynamic> json) {
    final daysJson = json['days'];
    if (daysJson is! List<dynamic>) {
      throw const FormatException('Timetable days must be a list');
    }

    return TimetableResponseModel(
      classId: (json['classId'] as num).toInt(),
      classCode: json['classCode'] as String,
      className: json['className'] as String,
      semesterId: (json['semesterId'] as num).toInt(),
      semesterName: json['semesterName'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      days: daysJson
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Timetable day must be an object');
            }
            return TimetableDayModel.fromJson(item);
          })
          .toList(growable: false),
    );
  }

  TimetableWeek toEntity() {
    return TimetableWeek(
      classId: classId,
      classCode: classCode,
      className: className,
      semesterId: semesterId,
      semesterName: semesterName,
      weekStart: weekStart,
      weekEnd: weekEnd,
      days: List<TimetableDay>.unmodifiable(days.map((day) => day.toEntity())),
    );
  }
}
