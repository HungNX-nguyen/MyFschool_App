import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/linked_student.dart';
import '../../domain/repositories/parent_repository.dart';
import '../datasources/parent_remote_datasource.dart';

class ParentRepositoryImpl implements ParentRepository {
  const ParentRepositoryImpl(this._remoteDatasource, this._sessionStorage);

  final ParentRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  @override
  Future<List<LinkedStudent>> getLinkedStudents() async {
    final accessToken = await _sessionStorage.readAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        code: 'AUTH_SESSION_MISSING',
        message: 'Phiên đăng nhập không tồn tại',
      );
    }

    final models = await _remoteDatasource.getLinkedStudents(accessToken);
    return List<LinkedStudent>.unmodifiable(
      models.map((model) => model.toEntity()),
    );
  }
}
