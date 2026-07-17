import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myfschoolse1913/src/core/network/api_client.dart';
import 'package:myfschoolse1913/src/features/school_event/data/datasources/school_event_remote_datasource.dart';
import 'package:myfschoolse1913/src/features/school_event/domain/entities/school_event.dart';

void main() {
  test(
    'calls Parent and Student event APIs with filters and access token',
    () async {
      final requestedPaths = <String>[];
      final apiClient = ApiClient(
        httpClient: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer event-token');
          requestedPaths.add(request.url.path);

          if (request.url.path.endsWith('/parent/students/29/events')) {
            expect(request.url.queryParameters, <String, String>{
              'timeRange': 'UPCOMING',
              'scope': 'ALL',
            });
            return _successResponse(
              studentId: 29,
              timeRange: 'UPCOMING',
              scope: 'ALL',
            );
          }

          expect(request.url.path, '/api/v1/student/me/events');
          expect(request.url.queryParameters, <String, String>{
            'timeRange': 'PAST',
            'scope': 'SCHOOL',
          });
          return _successResponse(
            studentId: 30,
            timeRange: 'PAST',
            scope: 'SCHOOL',
          );
        }),
      );
      addTearDown(apiClient.close);
      final datasource = SchoolEventRemoteDatasource(apiClient);

      final parentFeed = await datasource.getParentStudentEvents(
        accessToken: 'event-token',
        studentId: 29,
        timeRange: SchoolEventTimeRange.upcoming,
        scope: SchoolEventViewScope.all,
      );
      final studentFeed = await datasource.getStudentEvents(
        accessToken: 'event-token',
        timeRange: SchoolEventTimeRange.past,
        scope: SchoolEventViewScope.school,
      );

      expect(requestedPaths, <String>[
        '/api/v1/parent/students/29/events',
        '/api/v1/student/me/events',
      ]);
      expect(parentFeed.studentId, 29);
      expect(parentFeed.items.single.title, 'Họp phụ huynh lớp 12A1');
      expect(parentFeed.items.single.scope, SchoolEventScope.classEvent);
      expect(
        parentFeed.items.single.participationType,
        SchoolEventParticipationType.required,
      );
      expect(studentFeed.studentId, 30);
      expect(studentFeed.timeRange, SchoolEventTimeRange.past);
      expect(studentFeed.scope, SchoolEventViewScope.school);
    },
  );
}

http.Response _successResponse({
  required int studentId,
  required String timeRange,
  required String scope,
}) {
  return http.Response(
    jsonEncode(<String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'studentId': studentId,
        'classId': 3,
        'classCode': '12A1',
        'timeRange': timeRange,
        'scope': scope,
        'items': <Map<String, Object?>>[
          <String, Object?>{
            'id': 10,
            'title': 'Họp phụ huynh lớp 12A1',
            'description': 'Trao đổi kết quả học tập.',
            'scope': 'CLASS',
            'classId': 3,
            'classCode': '12A1',
            'eventDate': '2026-08-15',
            'startTime': '08:00:00',
            'endTime': '11:30:00',
            'isAllDay': false,
            'location': 'Lớp học 12A1',
            'participationType': 'REQUIRED',
          },
        ],
      },
      'message': 'Success',
    }),
    200,
    headers: const <String, String>{
      'content-type': 'application/json; charset=utf-8',
    },
  );
}
