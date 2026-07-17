import '../../domain/entities/timetable_week.dart';

class TimetableSlotModel {
  const TimetableSlotModel({
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

  factory TimetableSlotModel.fromJson(Map<String, dynamic> json) {
    return TimetableSlotModel(
      timetableId: (json['timetableId'] as num?)?.toInt(),
      slotIndex: (json['slotIndex'] as num).toInt(),
      displaySlotIndex: (json['displaySlotIndex'] as num).toInt(),
      shift: _parseShift(json['shift'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      subjectId: (json['subjectId'] as num?)?.toInt(),
      subjectCode: json['subjectCode'] as String?,
      subjectName: json['subjectName'] as String,
      teacherId: (json['teacherId'] as num?)?.toInt(),
      teacherName: json['teacherName'] as String?,
      classId: (json['classId'] as num?)?.toInt(),
      classCode: json['classCode'] as String?,
      className: json['className'] as String?,
      studyGroupId: (json['studyGroupId'] as num?)?.toInt(),
      studyGroupCode: json['studyGroupCode'] as String?,
      studyGroupName: json['studyGroupName'] as String?,
      room: json['room'] as String?,
      fixedActivity: json['fixedActivity'] as bool,
    );
  }

  TimetableSlot toEntity() {
    return TimetableSlot(
      timetableId: timetableId,
      slotIndex: slotIndex,
      displaySlotIndex: displaySlotIndex,
      shift: shift,
      startTime: startTime,
      endTime: endTime,
      subjectId: subjectId,
      subjectCode: subjectCode,
      subjectName: subjectName,
      teacherId: teacherId,
      teacherName: teacherName,
      classId: classId,
      classCode: classCode,
      className: className,
      studyGroupId: studyGroupId,
      studyGroupCode: studyGroupCode,
      studyGroupName: studyGroupName,
      room: room,
      fixedActivity: fixedActivity,
    );
  }

  static TimetableShift _parseShift(String value) {
    return switch (value) {
      'MORNING' => TimetableShift.morning,
      'AFTERNOON' => TimetableShift.afternoon,
      _ => throw FormatException('Unknown timetable shift: $value'),
    };
  }
}
