enum TimetableShift { morning, afternoon }

class TimetableWeek {
  const TimetableWeek({
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
  final List<TimetableDay> days;
}

class TimetableDay {
  const TimetableDay({
    required this.dayOfWeek,
    required this.date,
    required this.slots,
  });

  final int dayOfWeek;
  final DateTime date;
  final List<TimetableSlot> slots;
}

class TimetableSlot {
  const TimetableSlot({
    required this.slotIndex,
    required this.displaySlotIndex,
    required this.shift,
    required this.startTime,
    required this.endTime,
    required this.subjectName,
    required this.fixedActivity,
    this.timetableId,
    this.subjectId,
    this.subjectCode,
    this.teacherId,
    this.teacherName,
    this.classId,
    this.classCode,
    this.className,
    this.studyGroupId,
    this.studyGroupCode,
    this.studyGroupName,
    this.room,
  });

  final int? timetableId;
  final int slotIndex;
  final int displaySlotIndex;
  final TimetableShift shift;
  final String startTime;
  final String endTime;
  final int? subjectId;
  final String? subjectCode;
  final String subjectName;
  final int? teacherId;
  final String? teacherName;
  final int? classId;
  final String? classCode;
  final String? className;
  final int? studyGroupId;
  final String? studyGroupCode;
  final String? studyGroupName;
  final String? room;
  final bool fixedActivity;
}
