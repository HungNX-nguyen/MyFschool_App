import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/homeroom_class.dart';
import '../../domain/entities/homeroom_timetable.dart';
import '../../domain/repositories/homeroom_repository.dart';
import '../datasources/homeroom_remote_datasource.dart';

class HomeroomRepositoryImpl implements HomeroomRepository {
  const HomeroomRepositoryImpl(this._remoteDatasource, this._sessionStorage);

  final HomeroomRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  @override
  Future<List<HomeroomClassSummary>> getHomeroomClasses() async {
    final models = await _remoteDatasource.getHomeroomClasses(
      accessToken: await _requireAccessToken(),
    );
    return List<HomeroomClassSummary>.unmodifiable(
      models.map((model) => model.toEntity()),
    );
  }

  @override
  Future<HomeroomClassRoster> getClassRoster(int classId) async {
    final model = await _remoteDatasource.getClassRoster(
      accessToken: await _requireAccessToken(),
      classId: classId,
    );
    return model.toEntity();
  }

  @override
  Future<HomeroomTimetableWeek> getClassTimetable({
    required int classId,
    required DateTime weekStart,
    int? semesterId,
    int? studyGroupId,
  }) async {
    final model = await _remoteDatasource.getClassTimetable(
      accessToken: await _requireAccessToken(),
      classId: classId,
      weekStart: weekStart,
      semesterId: semesterId,
      studyGroupId: studyGroupId,
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
