import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/school_event.dart';
import '../../domain/repositories/school_event_repository.dart';
import '../datasources/school_event_remote_datasource.dart';

class SchoolEventRepositoryImpl implements SchoolEventRepository {
  const SchoolEventRepositoryImpl(this._remoteDatasource, this._sessionStorage);

  final SchoolEventRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  @override
  Future<SchoolEvent> getAccessibleEventDetail(int eventId) async {
    final model = await _remoteDatasource.getAccessibleEventDetail(
      accessToken: await _requireAccessToken(),
      eventId: eventId,
    );
    return model.toEntity();
  }

  @override
  Future<SchoolEventFeed> getParentStudentEvents({
    required int studentId,
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) async {
    final model = await _remoteDatasource.getParentStudentEvents(
      accessToken: await _requireAccessToken(),
      studentId: studentId,
      timeRange: timeRange,
      scope: scope,
    );
    return model.toEntity();
  }

  @override
  Future<SchoolEventFeed> getStudentEvents({
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) async {
    final model = await _remoteDatasource.getStudentEvents(
      accessToken: await _requireAccessToken(),
      timeRange: timeRange,
      scope: scope,
    );
    return model.toEntity();
  }

  Future<String> _requireAccessToken() async {
    final accessToken = await _sessionStorage.readAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        code: 'AUTH_SESSION_MISSING',
        message: 'Phiên đăng nhập không tồn tại',
      );
    }
    return accessToken;
  }
}
