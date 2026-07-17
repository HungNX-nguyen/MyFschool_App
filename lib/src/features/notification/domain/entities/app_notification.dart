enum AppNotificationType {
  grade,
  leave,
  absence,
  tuition,
  club,
  announcement,
  event,
  system,
}

class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.contentPreview,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.readAt,
    this.relatedEntityType,
    this.relatedEntityId,
  });

  final int id;
  final String title;
  final String contentPreview;
  final AppNotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final String? relatedEntityType;
  final int? relatedEntityId;

  AppNotificationItem markRead({DateTime? at}) {
    return AppNotificationItem(
      id: id,
      title: title,
      contentPreview: contentPreview,
      type: type,
      createdAt: createdAt,
      isRead: true,
      readAt: readAt ?? at,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
    );
  }
}

class AppNotificationNavigationTarget {
  const AppNotificationNavigationTarget({required this.type, required this.id});

  final String type;
  final int id;
}

class AppNotificationDetail {
  const AppNotificationDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.readAt,
    this.relatedEntityType,
    this.relatedEntityId,
    this.navigationTarget,
  });

  final int id;
  final String title;
  final String content;
  final AppNotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final String? relatedEntityType;
  final int? relatedEntityId;
  final AppNotificationNavigationTarget? navigationTarget;
}

class AppNotificationPageData {
  const AppNotificationPageData({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.unreadCount,
  });

  final List<AppNotificationItem> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final int unreadCount;
}

class MarkAllNotificationsReadResult {
  const MarkAllNotificationsReadResult({
    required this.updatedCount,
    required this.unreadCount,
  });

  final int updatedCount;
  final int unreadCount;
}
