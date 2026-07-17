import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/features/notification/domain/entities/app_notification.dart';
import 'package:myfschoolse1913/src/features/notification/domain/repositories/app_notification_repository.dart';
import 'package:myfschoolse1913/src/features/notification/presentation/controllers/app_notification_controller.dart';
import 'package:myfschoolse1913/src/features/notification/presentation/pages/app_notification_detail_sheet.dart';
import 'package:myfschoolse1913/src/features/notification/presentation/pages/app_notification_page.dart';
import 'package:myfschoolse1913/src/features/school_event/domain/entities/school_event.dart';
import 'package:myfschoolse1913/src/features/school_event/domain/repositories/school_event_repository.dart';

void main() {
  testWidgets(
    'renders notification list and unread badge on Pixel 6 Pro size',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 3120);
      tester.view.devicePixelRatio = 3.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AppNotificationController(
        _PageNotificationRepository(),
        _PageSchoolEventRepository(),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: AppNotificationPage(
            controller: controller,
            onAccountTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Thông báo'), findsWidgets);
      expect(find.byKey(const ValueKey('notification-item-1')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('notification-unread-badge')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('notification-item-1')));
      await tester.pumpAndSettle();

      expect(find.byType(AppNotificationDetailSheet), findsOneWidget);
      expect(
        tester.getSize(find.byType(AppNotificationDetailSheet)).width,
        greaterThan(380),
      );
      expect(
        find.descendant(
          of: find.byType(AppNotificationDetailSheet),
          matching: find.text(
            'Kính mời phụ huynh tham dự cuộc họp của lớp.',
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

class _PageNotificationRepository implements AppNotificationRepository {
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
          title: 'Họp phụ huynh tổng kết năm học',
          contentPreview: 'Kính mời phụ huynh tham dự cuộc họp của lớp.',
          type: AppNotificationType.announcement,
          createdAt: DateTime(2026, 7, 17, 8),
          isRead: false,
        ),
      ],
      page: 0,
      size: 20,
      totalElements: 1,
      totalPages: 1,
      unreadCount: 1,
    );
  }

  @override
  Future<int> getUnreadCount() async => 1;

  @override
  Future<AppNotificationDetail> getNotification(int notificationId) {
    throw UnimplementedError();
  }

  @override
  Future<AppNotificationDetail> markNotificationRead(int notificationId) {
    return Future<AppNotificationDetail>.value(
      AppNotificationDetail(
        id: notificationId,
        title: 'Họp phụ huynh tổng kết năm học',
        content: 'Kính mời phụ huynh tham dự cuộc họp của lớp.',
        type: AppNotificationType.announcement,
        createdAt: DateTime(2026, 7, 17, 8),
        isRead: true,
        readAt: DateTime(2026, 7, 17, 9),
      ),
    );
  }

  @override
  Future<MarkAllNotificationsReadResult> markAllRead() {
    throw UnimplementedError();
  }
}

class _PageSchoolEventRepository implements SchoolEventRepository {
  @override
  Future<SchoolEvent> getAccessibleEventDetail(int eventId) {
    throw UnimplementedError();
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
