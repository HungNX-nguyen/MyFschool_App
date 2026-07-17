import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/core/network/api_exception.dart';
import 'package:myfschoolse1913/src/features/school_event/domain/entities/school_event.dart';
import 'package:myfschoolse1913/src/features/school_event/domain/repositories/school_event_repository.dart';
import 'package:myfschoolse1913/src/features/school_event/presentation/controllers/school_event_controller.dart';

void main() {
  test('Parent loads linked student events and changes filters', () async {
    final repository = _RecordingSchoolEventRepository();
    final controller = SchoolEventController(
      repository,
      audience: SchoolEventAudience.parent,
      studentId: 29,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    await controller.selectTimeRange(SchoolEventTimeRange.past);
    await controller.selectScope(SchoolEventViewScope.classEvent);

    expect(controller.status, SchoolEventStatus.success);
    expect(controller.selectedTimeRange, SchoolEventTimeRange.past);
    expect(controller.selectedScope, SchoolEventViewScope.classEvent);
    expect(repository.parentStudentIds, <int>[29, 29, 29]);
    expect(repository.requestedTimeRanges, <SchoolEventTimeRange>[
      SchoolEventTimeRange.upcoming,
      SchoolEventTimeRange.past,
      SchoolEventTimeRange.past,
    ]);
    expect(repository.requestedScopes, <SchoolEventViewScope>[
      SchoolEventViewScope.all,
      SchoolEventViewScope.all,
      SchoolEventViewScope.classEvent,
    ]);
  });

  test('maps network failure for Student event screen', () async {
    final controller = SchoolEventController(
      const _ErrorSchoolEventRepository(),
      audience: SchoolEventAudience.student,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();

    expect(controller.status, SchoolEventStatus.error);
    expect(
      controller.errorMessage,
      'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
    );
  });
}

class _RecordingSchoolEventRepository implements SchoolEventRepository {
  final List<int> parentStudentIds = <int>[];
  final List<SchoolEventTimeRange> requestedTimeRanges =
      <SchoolEventTimeRange>[];
  final List<SchoolEventViewScope> requestedScopes = <SchoolEventViewScope>[];

  @override
  Future<SchoolEvent> getAccessibleEventDetail(int eventId) {
    throw UnimplementedError();
  }

  @override
  Future<SchoolEventFeed> getParentStudentEvents({
    required int studentId,
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) async {
    parentStudentIds.add(studentId);
    return _recordAndBuild(studentId, timeRange, scope);
  }

  @override
  Future<SchoolEventFeed> getStudentEvents({
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) async {
    return _recordAndBuild(30, timeRange, scope);
  }

  SchoolEventFeed _recordAndBuild(
    int studentId,
    SchoolEventTimeRange timeRange,
    SchoolEventViewScope scope,
  ) {
    requestedTimeRanges.add(timeRange);
    requestedScopes.add(scope);
    return SchoolEventFeed(
      studentId: studentId,
      classId: 3,
      classCode: '12A1',
      timeRange: timeRange,
      scope: scope,
      items: const <SchoolEvent>[],
    );
  }
}

class _ErrorSchoolEventRepository implements SchoolEventRepository {
  const _ErrorSchoolEventRepository();

  static const _error = ApiException(
    code: 'NETWORK_ERROR',
    message: 'Network error',
  );

  @override
  Future<SchoolEvent> getAccessibleEventDetail(int eventId) {
    throw _error;
  }

  @override
  Future<SchoolEventFeed> getParentStudentEvents({
    required int studentId,
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) {
    throw _error;
  }

  @override
  Future<SchoolEventFeed> getStudentEvents({
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) {
    throw _error;
  }
}
