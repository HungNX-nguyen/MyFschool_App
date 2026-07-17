enum SchoolEventScope { school, classEvent }

extension SchoolEventScopeApiValue on SchoolEventScope {
  String get apiValue => switch (this) {
    SchoolEventScope.school => 'SCHOOL',
    SchoolEventScope.classEvent => 'CLASS',
  };
}

enum SchoolEventParticipationType { required, optional }

extension SchoolEventParticipationTypeApiValue on SchoolEventParticipationType {
  String get apiValue => switch (this) {
    SchoolEventParticipationType.required => 'REQUIRED',
    SchoolEventParticipationType.optional => 'OPTIONAL',
  };
}

enum SchoolEventTimeRange { upcoming, past }

extension SchoolEventTimeRangeApiValue on SchoolEventTimeRange {
  String get apiValue => switch (this) {
    SchoolEventTimeRange.upcoming => 'UPCOMING',
    SchoolEventTimeRange.past => 'PAST',
  };
}

enum SchoolEventViewScope { all, classEvent, school }

extension SchoolEventViewScopeApiValue on SchoolEventViewScope {
  String get apiValue => switch (this) {
    SchoolEventViewScope.all => 'ALL',
    SchoolEventViewScope.classEvent => 'CLASS',
    SchoolEventViewScope.school => 'SCHOOL',
  };
}

class SchoolEvent {
  const SchoolEvent({
    required this.id,
    required this.title,
    required this.scope,
    required this.eventDate,
    required this.isAllDay,
    required this.participationType,
    this.description,
    this.classId,
    this.classCode,
    this.startTime,
    this.endTime,
    this.location,
  });

  final int id;
  final String title;
  final String? description;
  final SchoolEventScope scope;
  final int? classId;
  final String? classCode;
  final DateTime eventDate;
  final String? startTime;
  final String? endTime;
  final bool isAllDay;
  final String? location;
  final SchoolEventParticipationType participationType;
}

class SchoolEventFeed {
  const SchoolEventFeed({
    required this.studentId,
    required this.timeRange,
    required this.scope,
    required this.items,
    this.classId,
    this.classCode,
  });

  final int studentId;
  final int? classId;
  final String? classCode;
  final SchoolEventTimeRange timeRange;
  final SchoolEventViewScope scope;
  final List<SchoolEvent> items;
}
