import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/teacher_communication.dart';
import '../../domain/repositories/teacher_communication_repository.dart';
import '../datasources/teacher_communication_remote_datasource.dart';
import '../models/teacher_communication_payloads.dart';

class TeacherCommunicationRepositoryImpl
    implements TeacherCommunicationRepository {
  const TeacherCommunicationRepositoryImpl(
    this._remoteDatasource,
    this._sessionStorage,
  );

  final TeacherCommunicationRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  @override
  Future<List<ActiveHomeroomClass>> getActiveHomeroomClasses() async {
    final models = await _remoteDatasource.getActiveHomeroomClasses(
      accessToken: await _requireAccessToken(),
    );
    return List<ActiveHomeroomClass>.unmodifiable(
      models.map((model) => model.toEntity()),
    );
  }

  @override
  Future<ClassNotificationSendResult> sendClassNotification({
    required int classId,
    required String title,
    required String content,
    required ClassNotificationAudience audience,
  }) async {
    final model = await _remoteDatasource.sendClassNotification(
      accessToken: await _requireAccessToken(),
      classId: classId,
      payload: SendClassNotificationPayload(
        title: title,
        content: content,
        audience: audience,
      ),
    );
    return model.toEntity();
  }

  @override
  Future<ClassEventCreationResult> createClassEvent({
    required int classId,
    required CreateTeacherClassEvent event,
  }) async {
    final model = await _remoteDatasource.createClassEvent(
      accessToken: await _requireAccessToken(),
      classId: classId,
      payload: CreateClassEventPayload(event),
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
