import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/src/core/network/api_exception.dart';
import 'package:myfschoolse1913/src/features/parent/domain/entities/linked_student.dart';
import 'package:myfschoolse1913/src/features/parent/domain/repositories/parent_repository.dart';
import 'package:myfschoolse1913/src/features/parent/presentation/controllers/parent_home_controller.dart';

void main() {
  const firstStudent = LinkedStudent(
    id: 1,
    studentCode: 'STU0001',
    fullName: 'Nguyễn Minh An',
    className: '10A1',
    isPrimaryContact: true,
  );
  const secondStudent = LinkedStudent(
    id: 2,
    studentCode: 'STU0002',
    fullName: 'Nguyễn Minh Bình',
    isPrimaryContact: false,
  );

  test('loads linked students and selects the first student', () async {
    final repository = _FakeParentRepository(
      results: const <List<LinkedStudent>>[
        <LinkedStudent>[firstStudent, secondStudent],
      ],
    );
    final controller = ParentHomeController(repository);

    await controller.loadStudents();

    expect(controller.status, ParentHomeStatus.success);
    expect(controller.students, hasLength(2));
    expect(controller.selectedStudent, same(firstStudent));
    expect(controller.hasMultipleStudents, isTrue);
    expect(controller.errorMessage, isNull);
  });

  test('returns a successful empty state when parent has no links', () async {
    final repository = _FakeParentRepository(
      results: const <List<LinkedStudent>>[<LinkedStudent>[]],
    );
    final controller = ParentHomeController(repository);

    await controller.loadStudents();

    expect(controller.status, ParentHomeStatus.success);
    expect(controller.selectedStudent, isNull);
    expect(controller.hasNoLinkedStudents, isTrue);
  });

  test('selects only a student contained in the loaded list', () async {
    final repository = _FakeParentRepository(
      results: const <List<LinkedStudent>>[
        <LinkedStudent>[firstStudent, secondStudent],
      ],
    );
    final controller = ParentHomeController(repository);
    await controller.loadStudents();

    expect(controller.selectStudent(secondStudent.id), isTrue);
    expect(controller.selectedStudent, same(secondStudent));
    expect(controller.selectStudent(999), isFalse);
    expect(controller.selectedStudent, same(secondStudent));
  });

  test('preserves the selected student when data is refreshed', () async {
    final refreshedSecondStudent = LinkedStudent(
      id: secondStudent.id,
      studentCode: secondStudent.studentCode,
      fullName: '${secondStudent.fullName} Updated',
      isPrimaryContact: secondStudent.isPrimaryContact,
    );
    final repository = _FakeParentRepository(
      results: <List<LinkedStudent>>[
        const <LinkedStudent>[firstStudent, secondStudent],
        <LinkedStudent>[firstStudent, refreshedSecondStudent],
      ],
    );
    final controller = ParentHomeController(repository);
    await controller.loadStudents();
    controller.selectStudent(secondStudent.id);

    await controller.loadStudents();

    expect(controller.selectedStudent, same(refreshedSecondStudent));
  });

  test('maps network errors to a user-friendly message', () async {
    final repository = _FakeParentRepository(
      error: const ApiException(
        code: 'NETWORK_ERROR',
        message: 'Network failed',
      ),
    );
    final controller = ParentHomeController(repository);

    await controller.loadStudents();

    expect(controller.status, ParentHomeStatus.error);
    expect(controller.errorMessage, contains('kết nối đến máy chủ'));
  });

  test('ignores a second load while the first load is pending', () async {
    final completer = Completer<List<LinkedStudent>>();
    final repository = _FakeParentRepository(completer: completer);
    final controller = ParentHomeController(repository);

    final firstLoad = controller.loadStudents();
    await controller.loadStudents();

    expect(repository.callCount, 1);
    expect(controller.status, ParentHomeStatus.loading);

    completer.complete(const <LinkedStudent>[firstStudent]);
    await firstLoad;
    expect(controller.status, ParentHomeStatus.success);
  });
}

class _FakeParentRepository implements ParentRepository {
  _FakeParentRepository({
    this.results = const <List<LinkedStudent>>[],
    this.error,
    this.completer,
  });

  final List<List<LinkedStudent>> results;
  final Object? error;
  final Completer<List<LinkedStudent>>? completer;

  int callCount = 0;

  @override
  Future<List<LinkedStudent>> getLinkedStudents() async {
    final callIndex = callCount++;
    if (error != null) {
      throw error!;
    }
    if (completer != null) {
      return completer!.future;
    }
    return results[callIndex];
  }
}
