import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myfschoolse1913/src/core/network/api_client.dart';
import 'package:myfschoolse1913/src/features/school_event/domain/entities/school_event.dart';
import 'package:myfschoolse1913/src/features/teacher_communication/data/datasources/teacher_communication_remote_datasource.dart';
import 'package:myfschoolse1913/src/features/teacher_communication/data/models/teacher_communication_payloads.dart';
import 'package:myfschoolse1913/src/features/teacher_communication/domain/entities/teacher_communication.dart';

void main() {
  test('calls active class, notification and class event APIs', () async {
    final requestedPaths = <String>[];
    final apiClient = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer teacher-token');
        requestedPaths.add(request.url.path);

        if (request.method == 'GET') {
          expect(request.url.path, '/api/v1/teacher/me/homeroom-classes');
          expect(request.url.queryParameters['academicYearStatus'], 'ACTIVE');
          return _success(<Map<String, Object?>>[
            <String, Object?>{
              'classId': 30,
              'classCode': '10A1',
              'className': 'Lớp 10A1',
              'academicYearId': 1,
              'academicYearName': '2026-2027',
            },
          ]);
        }

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (request.url.path.endsWith('/teacher/notifications/classes/30')) {
          expect(body, <String, Object?>{
            'title': 'Nhắc lịch kiểm tra',
            'content': 'Chuẩn bị bài ngày mai.',
            'recipientType': 'PARENT_AND_STUDENT',
          });
          return _success(<String, Object?>{
            'notificationId': 100,
            'recipientCount': 28,
            'createdAt': '2026-07-17T10:30:00',
          });
        }

        expect(request.url.path, '/api/v1/teacher/homeroom/classes/30/events');
        expect(body, <String, Object?>{
          'title': 'Họp phụ huynh',
          'description': 'Họp tại lớp 10A1.',
          'eventDate': '2026-08-15',
          'allDay': false,
          'startTime': '08:00:00',
          'endTime': '10:00:00',
          'location': 'Phòng A101',
          'participationType': 'REQUIRED',
          'publishNow': true,
        });
        return _success(<String, Object?>{
          'eventId': 50,
          'status': 'PUBLISHED',
          'publishedAt': '2026-07-17T11:00:00',
        });
      }),
    );
    addTearDown(apiClient.close);
    final datasource = TeacherCommunicationRemoteDatasource(apiClient);

    final classes = await datasource.getActiveHomeroomClasses(
      accessToken: 'teacher-token',
    );
    final notification = await datasource.sendClassNotification(
      accessToken: 'teacher-token',
      classId: 30,
      payload: const SendClassNotificationPayload(
        title: 'Nhắc lịch kiểm tra',
        content: 'Chuẩn bị bài ngày mai.',
        audience: ClassNotificationAudience.parentAndStudent,
      ),
    );
    final event = await datasource.createClassEvent(
      accessToken: 'teacher-token',
      classId: 30,
      payload: CreateClassEventPayload(
        CreateTeacherClassEvent(
          title: 'Họp phụ huynh',
          description: 'Họp tại lớp 10A1.',
          eventDate: DateTime(2026, 8, 15),
          isAllDay: false,
          startTime: const Duration(hours: 8),
          endTime: const Duration(hours: 10),
          location: 'Phòng A101',
          participationType: SchoolEventParticipationType.required,
          publishNow: true,
        ),
      ),
    );

    expect(requestedPaths, <String>[
      '/api/v1/teacher/me/homeroom-classes',
      '/api/v1/teacher/notifications/classes/30',
      '/api/v1/teacher/homeroom/classes/30/events',
    ]);
    expect(classes.single.classCode, '10A1');
    expect(notification.notificationId, 100);
    expect(notification.recipientCount, 28);
    expect(event.eventId, 50);
    expect(event.status, TeacherClassEventStatus.published);
  });
}

http.Response _success(Object? data) {
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
