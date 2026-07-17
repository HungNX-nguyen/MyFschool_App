import '../entities/school_event.dart';

abstract interface class SchoolEventRepository {
  Future<SchoolEvent> getAccessibleEventDetail(int eventId);

  Future<SchoolEventFeed> getParentStudentEvents({
    required int studentId,
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  });

  Future<SchoolEventFeed> getStudentEvents({
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  });
}
