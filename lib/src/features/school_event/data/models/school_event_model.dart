import '../../domain/entities/school_event.dart';

class SchoolEventModel {
  const SchoolEventModel({
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

  factory SchoolEventModel.fromJson(Map<String, dynamic> json) {
    return SchoolEventModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      scope: _parseEventScope(json['scope']),
      classId: (json['classId'] as num?)?.toInt(),
      classCode: json['classCode'] as String?,
      eventDate: DateTime.parse(json['eventDate'] as String),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      isAllDay: json['isAllDay'] as bool,
      location: json['location'] as String?,
      participationType: _parseParticipationType(json['participationType']),
    );
  }

  SchoolEvent toEntity() {
    return SchoolEvent(
      id: id,
      title: title,
      description: description,
      scope: scope,
      classId: classId,
      classCode: classCode,
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      location: location,
      participationType: participationType,
    );
  }
}

class SchoolEventFeedModel {
  const SchoolEventFeedModel({
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
  final List<SchoolEventModel> items;

  factory SchoolEventFeedModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List<dynamic>) {
      throw const FormatException('School event items must be a list');
    }

    return SchoolEventFeedModel(
      studentId: (json['studentId'] as num).toInt(),
      classId: (json['classId'] as num?)?.toInt(),
      classCode: json['classCode'] as String?,
      timeRange: _parseTimeRange(json['timeRange']),
      scope: _parseViewScope(json['scope']),
      items: List<SchoolEventModel>.unmodifiable(
        rawItems.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('School event must be an object');
          }
          return SchoolEventModel.fromJson(item);
        }),
      ),
    );
  }

  SchoolEventFeed toEntity() {
    return SchoolEventFeed(
      studentId: studentId,
      classId: classId,
      classCode: classCode,
      timeRange: timeRange,
      scope: scope,
      items: List<SchoolEvent>.unmodifiable(
        items.map((item) => item.toEntity()),
      ),
    );
  }
}

SchoolEventScope _parseEventScope(Object? value) {
  return switch (value) {
    'SCHOOL' => SchoolEventScope.school,
    'CLASS' => SchoolEventScope.classEvent,
    _ => throw FormatException('Unknown school event scope: $value'),
  };
}

SchoolEventParticipationType _parseParticipationType(Object? value) {
  return switch (value) {
    'REQUIRED' => SchoolEventParticipationType.required,
    'OPTIONAL' => SchoolEventParticipationType.optional,
    _ => throw FormatException('Unknown participation type: $value'),
  };
}

SchoolEventTimeRange _parseTimeRange(Object? value) {
  return switch (value) {
    'UPCOMING' => SchoolEventTimeRange.upcoming,
    'PAST' => SchoolEventTimeRange.past,
    _ => throw FormatException('Unknown school event time range: $value'),
  };
}

SchoolEventViewScope _parseViewScope(Object? value) {
  return switch (value) {
    'ALL' => SchoolEventViewScope.all,
    'CLASS' => SchoolEventViewScope.classEvent,
    'SCHOOL' => SchoolEventViewScope.school,
    _ => throw FormatException('Unknown school event view scope: $value'),
  };
}
