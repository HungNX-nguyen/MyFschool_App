import '../../../timetable/domain/entities/timetable_week.dart';

class HomeroomStudyGroup {
  const HomeroomStudyGroup({
    required this.studyGroupId,
    required this.studyGroupCode,
    required this.studyGroupName,
  });

  final int studyGroupId;
  final String studyGroupCode;
  final String studyGroupName;
}

class HomeroomTimetableWeek {
  const HomeroomTimetableWeek({
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
  final List<HomeroomStudyGroup> availableStudyGroups;
  final List<TimetableDay> days;
}
