import '../../domain/entities/app_notification.dart';

class AppNotificationItemModel {
  const AppNotificationItemModel(this.entity);

  final AppNotificationItem entity;

  factory AppNotificationItemModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationItemModel(
      AppNotificationItem(
        id: (json['notificationId'] as num).toInt(),
        title: json['title'] as String,
        contentPreview: json['contentPreview'] as String? ?? '',
        type: _parseType(json['type']),
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool,
        readAt: _parseNullableDateTime(json['readAt']),
        relatedEntityType: json['relatedEntityType'] as String?,
        relatedEntityId: (json['relatedEntityId'] as num?)?.toInt(),
      ),
    );
  }
}

class AppNotificationDetailModel {
  const AppNotificationDetailModel(this.entity);

  final AppNotificationDetail entity;

  factory AppNotificationDetailModel.fromJson(Map<String, dynamic> json) {
    final rawTarget = json['navigationTarget'];
    AppNotificationNavigationTarget? target;
    if (rawTarget != null) {
      if (rawTarget is! Map<String, dynamic>) {
        throw const FormatException('Navigation target must be an object');
      }
      target = AppNotificationNavigationTarget(
        type: rawTarget['type'] as String,
        id: (rawTarget['id'] as num).toInt(),
      );
    }

    return AppNotificationDetailModel(
      AppNotificationDetail(
        id: (json['notificationId'] as num).toInt(),
        title: json['title'] as String,
        content: json['content'] as String,
        type: _parseType(json['type']),
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool,
        readAt: _parseNullableDateTime(json['readAt']),
        relatedEntityType: json['relatedEntityType'] as String?,
        relatedEntityId: (json['relatedEntityId'] as num?)?.toInt(),
        navigationTarget: target,
      ),
    );
  }
}

class AppNotificationPageModel {
  const AppNotificationPageModel(this.entity);

  final AppNotificationPageData entity;

  factory AppNotificationPageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List<dynamic>) {
      throw const FormatException('Notification items must be a list');
    }
    final items = rawItems
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Notification item must be an object');
          }
          return AppNotificationItemModel.fromJson(item).entity;
        })
        .toList(growable: false);

    return AppNotificationPageModel(
      AppNotificationPageData(
        items: List<AppNotificationItem>.unmodifiable(items),
        page: (json['page'] as num).toInt(),
        size: (json['size'] as num).toInt(),
        totalElements: (json['totalElements'] as num).toInt(),
        totalPages: (json['totalPages'] as num).toInt(),
        unreadCount: (json['unreadCount'] as num).toInt(),
      ),
    );
  }
}

AppNotificationType _parseType(Object? value) {
  return switch (value) {
    'GRADE' => AppNotificationType.grade,
    'LEAVE' => AppNotificationType.leave,
    'ABSENCE' => AppNotificationType.absence,
    'TUITION' => AppNotificationType.tuition,
    'CLUB' => AppNotificationType.club,
    'ANNOUNCEMENT' => AppNotificationType.announcement,
    'EVENT' => AppNotificationType.event,
    'SYSTEM' => AppNotificationType.system,
    _ => throw FormatException('Unknown notification type: $value'),
  };
}

DateTime? _parseNullableDateTime(Object? value) {
  return value == null ? null : DateTime.parse(value as String);
}
