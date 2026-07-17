import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/app_notification_repository.dart';
import '../datasources/app_notification_remote_datasource.dart';

class AppNotificationRepositoryImpl implements AppNotificationRepository {
  const AppNotificationRepositoryImpl(
    this._remoteDatasource,
    this._sessionStorage,
  );

  final AppNotificationRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  @override
  Future<AppNotificationPageData> getMyNotifications({
    required int page,
    required int size,
    bool? isRead,
  }) async {
    return _remoteDatasource.getMyNotifications(
      accessToken: await _requireAccessToken(),
      page: page,
      size: size,
      isRead: isRead,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    return _remoteDatasource.getUnreadCount(
      accessToken: await _requireAccessToken(),
    );
  }

  @override
  Future<AppNotificationDetail> getNotification(int notificationId) async {
    return _remoteDatasource.getNotification(
      accessToken: await _requireAccessToken(),
      notificationId: notificationId,
    );
  }

  @override
  Future<AppNotificationDetail> markNotificationRead(int notificationId) async {
    return _remoteDatasource.markNotificationRead(
      accessToken: await _requireAccessToken(),
      notificationId: notificationId,
    );
  }

  @override
  Future<MarkAllNotificationsReadResult> markAllRead() async {
    return _remoteDatasource.markAllRead(
      accessToken: await _requireAccessToken(),
    );
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
