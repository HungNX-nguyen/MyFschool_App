import '../entities/homeroom_class.dart';
import '../entities/homeroom_timetable.dart';

abstract interface class HomeroomRepository {
  Future<List<HomeroomClassSummary>> getHomeroomClasses();

  Future<HomeroomClassRoster> getClassRoster(int classId);

  Future<HomeroomTimetableWeek> getClassTimetable({
    required int classId,
    required DateTime weekStart,
    int? semesterId,
    int? studyGroupId,
  });
}
