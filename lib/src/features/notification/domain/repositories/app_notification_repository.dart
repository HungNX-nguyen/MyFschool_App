import '../entities/app_notification.dart';

abstract interface class AppNotificationRepository {
  Future<AppNotificationPageData> getMyNotifications({
    required int page,
    required int size,
    bool? isRead,
  });

  Future<int> getUnreadCount();

  Future<AppNotificationDetail> getNotification(int notificationId);

  Future<AppNotificationDetail> markNotificationRead(int notificationId);

  Future<MarkAllNotificationsReadResult> markAllRead();
}
