import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/linked_student.dart';
import '../../domain/repositories/parent_repository.dart';

enum ParentHomeStatus { idle, loading, success, error }

class ParentHomeController extends ChangeNotifier {
  ParentHomeController(this._parentRepository);

  final ParentRepository _parentRepository;

  ParentHomeStatus _status = ParentHomeStatus.idle;
  List<LinkedStudent> _students = const <LinkedStudent>[];
  LinkedStudent? _selectedStudent;
  String? _errorMessage;

  ParentHomeStatus get status => _status;
  List<LinkedStudent> get students => _students;
  LinkedStudent? get selectedStudent => _selectedStudent;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ParentHomeStatus.loading;
  bool get hasMultipleStudents => _students.length > 1;
  bool get hasNoLinkedStudents =>
      _status == ParentHomeStatus.success && _students.isEmpty;

  Future<void> loadStudents() async {
    if (isLoading) {
      return;
    }

    _setState(
      status: ParentHomeStatus.loading,
      students: _students,
      selectedStudent: _selectedStudent,
      errorMessage: null,
    );

    try {
      final students = await _parentRepository.getLinkedStudents();
      final selectedStudent = _resolveSelection(students);

      _setState(
        status: ParentHomeStatus.success,
        students: students,
        selectedStudent: selectedStudent,
        errorMessage: null,
      );
    } on ApiException catch (error) {
      _setState(
        status: ParentHomeStatus.error,
        students: _students,
        selectedStudent: _selectedStudent,
        errorMessage: _mapApiError(error),
      );
    } catch (_) {
      _setState(
        status: ParentHomeStatus.error,
        students: _students,
        selectedStudent: _selectedStudent,
        errorMessage: 'Đã xảy ra lỗi. Vui lòng thử lại.',
      );
    }
  }

  bool selectStudent(int studentId) {
    if (_selectedStudent?.id == studentId) {
      return true;
    }

    for (final student in _students) {
      if (student.id == studentId) {
        _selectedStudent = student;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  LinkedStudent? _resolveSelection(List<LinkedStudent> students) {
    if (students.isEmpty) {
      return null;
    }

    final currentStudentId = _selectedStudent?.id;
    if (currentStudentId != null) {
      for (final student in students) {
        if (student.id == currentStudentId) {
          return student;
        }
      }
    }
    return students.first;
  }

  String _mapApiError(ApiException error) {
    return switch (error.code) {
      'AUTH_SESSION_MISSING' =>
        'Phiên đăng nhập không tồn tại. Vui lòng đăng nhập lại.',
      'NETWORK_TIMEOUT' => 'Kết nối quá thời gian. Vui lòng thử lại.',
      'NETWORK_ERROR' =>
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      'FORBIDDEN' => 'Bạn không có quyền xem danh sách học sinh liên kết.',
      _ => error.message,
    };
  }

  void _setState({
    required ParentHomeStatus status,
    required List<LinkedStudent> students,
    required LinkedStudent? selectedStudent,
    required String? errorMessage,
  }) {
    _status = status;
    _students = List<LinkedStudent>.unmodifiable(students);
    _selectedStudent = selectedStudent;
    _errorMessage = errorMessage;
    notifyListeners();
  }
}
