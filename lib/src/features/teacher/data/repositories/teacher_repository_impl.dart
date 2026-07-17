import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/teacher_home_summary.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../datasources/teacher_remote_datasource.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  const TeacherRepositoryImpl(this._remoteDatasource, this._sessionStorage);

  final TeacherRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  @override
  Future<TeacherHomeSummary> getHomeSummary() async {
    final accessToken = await _sessionStorage.readAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        code: 'AUTH_SESSION_MISSING',
        message: 'Phiên đăng nhập không tồn tại',
      );
    }

    final model = await _remoteDatasource.getHomeSummary(accessToken);
    return model.toEntity();
  }
}
