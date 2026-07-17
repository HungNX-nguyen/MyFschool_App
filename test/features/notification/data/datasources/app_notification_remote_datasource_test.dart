import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myfschoolse1913/src/core/network/api_client.dart';
import 'package:myfschoolse1913/src/features/notification/data/datasources/app_notification_remote_datasource.dart';
import 'package:myfschoolse1913/src/features/notification/domain/entities/app_notification.dart';

void main() {
  test(
    'uses notification list, unread and read endpoints with bearer token',
    () async {
      final requestedPaths = <String>[];
      final apiClient = ApiClient(
        httpClient: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer notification-token');
          requestedPaths.add('${request.method} ${request.url.path}');

          if (request.url.path.endsWith('/unread-count')) {
            return _success(<String, Object?>{'unreadCount': 1});
          }
          if (request.url.path.endsWith('/read-all')) {
            return _success(<String, Object?>{
              'updatedCount': 1,
              'unreadCount': 0,
            });
          }
          if (request.url.path.endsWith('/7/read')) {
            return _success(_detailJson(isRead: true));
          }
          expect(request.url.queryParameters, <String, String>{
            'page': '0',
            'size': '20',
          });
          return _success(<String, Object?>{
            'items': <Map<String, Object?>>[_itemJson()],
            'page': 0,
            'size': 20,
            'totalElements': 1,
            'totalPages': 1,
            'unreadCount': 1,
          });
        }),
      );
      addTearDown(apiClient.close);
      final datasource = AppNotificationRemoteDatasource(apiClient);

      final page = await datasource.getMyNotifications(
        accessToken: 'notification-token',
        page: 0,
        size: 20,
      );
      final unread = await datasource.getUnreadCount(
        accessToken: 'notification-token',
      );
      final detail = await datasource.markNotificationRead(
        accessToken: 'notification-token',
        notificationId: 7,
      );
      final markAll = await datasource.markAllRead(
        accessToken: 'notification-token',
      );

      expect(page.items.single.type, AppNotificationType.event);
      expect(page.items.single.relatedEntityId, 55);
      expect(unread, 1);
      expect(detail.isRead, isTrue);
      expect(detail.navigationTarget?.id, 55);
      expect(markAll.unreadCount, 0);
      expect(requestedPaths, <String>[
        'GET /api/v1/notifications/me',
        'GET /api/v1/notifications/me/unread-count',
        'PATCH /api/v1/notifications/me/7/read',
        'PATCH /api/v1/notifications/me/read-all',
      ]);
    },
  );
}

Map<String, Object?> _itemJson() {
  return <String, Object?>{
    'notificationId': 7,
    'title': 'Sự kiện lớp',
    'contentPreview': 'Sự kiện mới đã được phát hành.',
    'type': 'EVENT',
    'createdAt': '2026-07-17T08:00:00',
    'isRead': false,
    'readAt': null,
    'relatedEntityType': 'SCHOOL_EVENT',
    'relatedEntityId': 55,
  };
}

Map<String, Object?> _detailJson({required bool isRead}) {
  return <String, Object?>{
    'notificationId': 7,
    'title': 'Sự kiện lớp',
    'content': 'Sự kiện mới đã được phát hành.',
    'type': 'EVENT',
    'createdAt': '2026-07-17T08:00:00',
    'isRead': isRead,
    'readAt': isRead ? '2026-07-17T09:00:00' : null,
    'relatedEntityType': 'SCHOOL_EVENT',
    'relatedEntityId': 55,
    'navigationTarget': <String, Object?>{'type': 'SCHOOL_EVENT', 'id': 55},
  };
}

http.Response _success(Object data) {
  return http.Response(
    jsonEncode(<String, Object?>{
      'success': true,
      'data': data,
      'message': 'Success',
    }),
    200,
    headers: const <String, String>{
      'content-type': 'application/json; charset=utf-8',
    },
  );
}
