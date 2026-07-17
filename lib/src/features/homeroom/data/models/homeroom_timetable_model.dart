import '../../../timetable/data/models/timetable_day_model.dart';
import '../../../timetable/domain/entities/timetable_week.dart';
import '../../domain/entities/homeroom_timetable.dart';

class HomeroomTimetableModel {
  const HomeroomTimetableModel({
    required this.classId,
    required this.classCode,
    required this.className,
    required this.semesterId,
    required this.semesterName,
    required this.weekStart,
    required this.weekEnd,
    required this.availableStudyGroups,
    required this.days,
    this.selectedStudyGroupId,
  });

  final int classId;
  final String classCode;
  final String className;
  final int semesterId;
  final String semesterName;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int? selectedStudyGroupId;
  final List<HomeroomStudyGroupModel> availableStudyGroups;
  final List<TimetableDayModel> days;

  factory HomeroomTimetableModel.fromJson(Map<String, dynamic> json) {
    final rawStudyGroups = json['availableStudyGroups'];
    final rawDays = json['days'];
    if (rawStudyGroups is! List<dynamic>) {
      throw const FormatException('Available study groups must be a list');
    }
    if (rawDays is! List<dynamic>) {
      throw const FormatException('Homeroom timetable days must be a list');
    }

    return HomeroomTimetableModel(
      classId: (json['classId'] as num).toInt(),
      classCode: json['classCode'] as String,
      className: json['className'] as String,
      semesterId: (json['semesterId'] as num).toInt(),
      semesterName: json['semesterName'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      selectedStudyGroupId: (json['selectedStudyGroupId'] as num?)?.toInt(),
      availableStudyGroups: List<HomeroomStudyGroupModel>.unmodifiable(
        rawStudyGroups.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Study group must be an object');
          }
          return HomeroomStudyGroupModel.fromJson(item);
        }),
      ),
      days: List<TimetableDayModel>.unmodifiable(
        rawDays.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Timetable day must be an object');
          }
          return TimetableDayModel.fromJson(item);
        }),
      ),
    );
  }

  HomeroomTimetableWeek toEntity() {
    return HomeroomTimetableWeek(
      classId: classId,
      classCode: classCode,
      className: className,
      semesterId: semesterId,
      semesterName: semesterName,
      weekStart: weekStart,
      weekEnd: weekEnd,
      selectedStudyGroupId: selectedStudyGroupId,
      availableStudyGroups: List<HomeroomStudyGroup>.unmodifiable(
        availableStudyGroups.map((group) => group.toEntity()),
      ),
      days: List<TimetableDay>.unmodifiable(days.map((day) => day.toEntity())),
    );
  }
}

class HomeroomStudyGroupModel {
  const HomeroomStudyGroupModel({
    required this.studyGroupId,
    required this.studyGroupCode,
    required this.studyGroupName,
  });

  final int studyGroupId;
  final String studyGroupCode;
  final String studyGroupName;

  factory HomeroomStudyGroupModel.fromJson(Map<String, dynamic> json) {
    return HomeroomStudyGroupModel(
      studyGroupId: (json['studyGroupId'] as num).toInt(),
      studyGroupCode: json['studyGroupCode'] as String,
      studyGroupName: json['studyGroupName'] as String,
    );
  }

  HomeroomStudyGroup toEntity() {
    return HomeroomStudyGroup(
      studyGroupId: studyGroupId,
      studyGroupCode: studyGroupCode,
      studyGroupName: studyGroupName,
    );
  }
}
