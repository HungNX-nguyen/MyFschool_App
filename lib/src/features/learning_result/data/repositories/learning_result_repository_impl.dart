import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/learning_result.dart';
import '../../domain/repositories/learning_result_repository.dart';
import '../datasources/learning_result_remote_datasource.dart';

class LearningResultRepositoryImpl implements LearningResultRepository {
  const LearningResultRepositoryImpl(
    this._remoteDatasource,
    this._sessionStorage,
  );

  final LearningResultRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  @override
  Future<LearningResultReport> getParentStudentResult({
    required int studentId,
    required LearningResultPeriod period,
    int? academicYearId,
  }) async {
    final accessToken = await _requireAccessToken();
    final model = await _remoteDatasource.getParentStudentResult(
      accessToken: accessToken,
      studentId: studentId,
      academicYearId: academicYearId,
      period: period,
    );
    return model.toEntity();
  }

  @override
  Future<LearningResultReport> getStudentResult({
    required LearningResultPeriod period,
    int? academicYearId,
  }) async {
    final accessToken = await _requireAccessToken();
    final model = await _remoteDatasource.getStudentResult(
      accessToken: accessToken,
      academicYearId: academicYearId,
      period: period,
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
