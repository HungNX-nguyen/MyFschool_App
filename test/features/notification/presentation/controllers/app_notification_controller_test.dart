import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/notification/domain/entities/app_notification.dart';
import 'package:myfschoolse1913/src/features/notification/domain/repositories/app_notification_repository.dart';
import 'package:myfschoolse1913/src/features/notification/presentation/controllers/app_notification_controller.dart';
import 'package:myfschoolse1913/src/features/school_event/domain/entities/school_event.dart';
import 'package:myfschoolse1913/src/features/school_event/domain/repositories/school_event_repository.dart';

void main() {
  test(
    'loads notifications and only reduces badge after an item is opened',
    () async {
      final notificationRepository = _NotificationRepository();
      final eventRepository = _SchoolEventRepository();
      final controller = AppNotificationController(
        notificationRepository,
        eventRepository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(controller.status, AppNotificationPageStatus.ready);
      expect(controller.items, hasLength(2));
      expect(controller.unreadCount, 2);

      final result = await controller.openNotification(1);

      expect(result?.detail.title, 'Thông báo lớp');
      expect(controller.items.first.isRead, isTrue);
      expect(controller.unreadCount, 1);
    },
  );

  test(
    'opens the related school event and mark-all clears remaining badge',
    () async {
      final notificationRepository = _NotificationRepository();
      final eventRepository = _SchoolEventRepository();
      final controller = AppNotificationController(
        notificationRepository,
        eventRepository,
      );
      addTearDown(controller.dispose);
      await controller.loadInitial();

      final result = await controller.openNotification(2);

      expect(result?.schoolEvent?.id, 55);
      expect(eventRepository.requestedEventId, 55);
      expect(controller.unreadCount, 1);

      expect(await controller.markAllRead(), isTrue);
      expect(controller.unreadCount, 0);
      expect(controller.items.every((item) => item.isRead), isTrue);
    },
  );
}

class _NotificationRepository implements AppNotificationRepository {
  final _createdAt = DateTime(2026, 7, 17, 8);

  @override
  Future<AppNotificationPageData> getMyNotifications({
    required int page,
    required int size,
    bool? isRead,
  }) async {
    return AppNotificationPageData(
      items: <AppNotificationItem>[
        AppNotificationItem(
          id: 1,
          title: 'Thông báo lớp',
          contentPreview: 'Nội dung thông báo',
          type: AppNotificationType.announcement,
          createdAt: _createdAt,
          isRead: false,
        ),
        AppNotificationItem(
          id: 2,
          title: 'Sự kiện lớp',
          contentPreview: 'Nội dung sự kiện',
          type: AppNotificationType.event,
          createdAt: _createdAt,
          isRead: false,
          relatedEntityType: 'SCHOOL_EVENT',
          relatedEntityId: 55,
        ),
      ],
      page: 0,
      size: 20,
      totalElements: 2,
      totalPages: 1,
      unreadCount: 2,
    );
  }

  @override
  Future<int> getUnreadCount() async => 2;

  @override
  Future<AppNotificationDetail> getNotification(int notificationId) {
    throw UnimplementedError();
  }

  @override
  Future<AppNotificationDetail> markNotificationRead(int notificationId) async {
    final isEvent = notificationId == 2;
    return AppNotificationDetail(
      id: notificationId,
      title: isEvent ? 'Sự kiện lớp' : 'Thông báo lớp',
      content: isEvent ? 'Nội dung sự kiện' : 'Nội dung thông báo',
      type: isEvent
          ? AppNotificationType.event
          : AppNotificationType.announcement,
      createdAt: _createdAt,
      isRead: true,
      readAt: DateTime(2026, 7, 17, 9),
      relatedEntityType: isEvent ? 'SCHOOL_EVENT' : null,
      relatedEntityId: isEvent ? 55 : null,
      navigationTarget: isEvent
          ? const AppNotificationNavigationTarget(type: 'SCHOOL_EVENT', id: 55)
          : null,
    );
  }

  @override
  Future<MarkAllNotificationsReadResult> markAllRead() async {
    return const MarkAllNotificationsReadResult(
      updatedCount: 1,
      unreadCount: 0,
    );
  }
}

class _SchoolEventRepository implements SchoolEventRepository {
  int? requestedEventId;

  @override
  Future<SchoolEvent> getAccessibleEventDetail(int eventId) async {
    requestedEventId = eventId;
    return SchoolEvent(
      id: eventId,
      title: 'Sự kiện lớp',
      scope: SchoolEventScope.classEvent,
      classId: 3,
      classCode: '12A1',
      eventDate: DateTime(2026, 8, 15),
      startTime: '08:00:00',
      endTime: '10:00:00',
      isAllDay: false,
      location: 'Phòng A101',
      participationType: SchoolEventParticipationType.required,
    );
  }

  @override
  Future<SchoolEventFeed> getParentStudentEvents({
    required int studentId,
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SchoolEventFeed> getStudentEvents({
    required SchoolEventTimeRange timeRange,
    required SchoolEventViewScope scope,
  }) {
    throw UnimplementedError();
  }
}
