import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/teacher_timetable_week.dart';
import '../../domain/entities/timetable_week.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../datasources/timetable_remote_datasource.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  const TimetableRepositoryImpl(this._remoteDatasource, this._sessionStorage);

  final TimetableRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  @override
  Future<TimetableWeek> getParentStudentTimetable({
    required int studentId,
    required DateTime weekStart,
    int? semesterId,
  }) async {
    final accessToken = await _requireAccessToken();
    final model = await _remoteDatasource.getParentStudentTimetable(
      accessToken: accessToken,
      studentId: studentId,
      semesterId: semesterId,
      weekStart: weekStart,
    );
    return model.toEntity();
  }

  @override
  Future<TimetableWeek> getStudentTimetable({
    required DateTime weekStart,
    int? semesterId,
  }) async {
    final accessToken = await _requireAccessToken();
    final model = await _remoteDatasource.getStudentTimetable(
      accessToken: accessToken,
      semesterId: semesterId,
      weekStart: weekStart,
    );
    return model.toEntity();
  }

  @override
  Future<TeacherTimetableWeek> getTeacherTimetable({
    required DateTime weekStart,
    int? semesterId,
  }) async {
    final accessToken = await _requireAccessToken();
    final model = await _remoteDatasource.getTeacherTimetable(
      accessToken: accessToken,
      semesterId: semesterId,
      weekStart: weekStart,
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
