import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/app_notification.dart';
import '../models/app_notification_models.dart';

class AppNotificationRemoteDatasource {
  const AppNotificationRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<AppNotificationPageData> getMyNotifications({
    required String accessToken,
    required int page,
    required int size,
    bool? isRead,
  }) async {
    final query = Uri(
      queryParameters: <String, String>{
        'page': '$page',
        'size': '$size',
        if (isRead != null) 'isRead': '$isRead',
      },
    ).query;
    final data = await _apiClient.get(
      '/notifications/me?$query',
      accessToken: accessToken,
    );
    return _parseObject(data, AppNotificationPageModel.fromJson).entity;
  }

  Future<int> getUnreadCount({required String accessToken}) async {
    final data = await _apiClient.get(
      '/notifications/me/unread-count',
      accessToken: accessToken,
    );
    final json = _requireObject(data);
    return (json['unreadCount'] as num).toInt();
  }

  Future<AppNotificationDetail> getNotification({
    required String accessToken,
    required int notificationId,
  }) async {
    final data = await _apiClient.get(
      '/notifications/me/$notificationId',
      accessToken: accessToken,
    );
    return _parseObject(data, AppNotificationDetailModel.fromJson).entity;
  }

  Future<AppNotificationDetail> markNotificationRead({
    required String accessToken,
    required int notificationId,
  }) async {
    final data = await _apiClient.patch(
      '/notifications/me/$notificationId/read',
      accessToken: accessToken,
    );
    return _parseObject(data, AppNotificationDetailModel.fromJson).entity;
  }

  Future<MarkAllNotificationsReadResult> markAllRead({
    required String accessToken,
  }) async {
    final data = await _apiClient.patch(
      '/notifications/me/read-all',
      accessToken: accessToken,
    );
    final json = _requireObject(data);
    return MarkAllNotificationsReadResult(
      updatedCount: (json['updatedCount'] as num).toInt(),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );
  }

  T _parseObject<T>(Object? data, T Function(Map<String, dynamic>) parser) {
    final json = _requireObject(data);
    try {
      return parser(json);
    } on FormatException catch (error) {
      throw _invalidResponse(error.message);
    } on TypeError catch (error) {
      throw _invalidResponse(error.toString());
    }
  }

  Map<String, dynamic> _requireObject(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw _invalidResponse('Notification response must be an object');
    }
    return data;
  }

  ApiException _invalidResponse(String details) {
    return ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Dữ liệu thông báo từ máy chủ không hợp lệ',
      details: details,
    );
  }
}
