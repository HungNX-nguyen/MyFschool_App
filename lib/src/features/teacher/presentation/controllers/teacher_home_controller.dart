import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/teacher_home_summary.dart';
import '../../domain/repositories/teacher_repository.dart';

enum TeacherHomeStatus { idle, loading, success, error }

class TeacherHomeController extends ChangeNotifier {
  TeacherHomeController(this._teacherRepository);

  final TeacherRepository _teacherRepository;

  TeacherHomeStatus _status = TeacherHomeStatus.idle;
  TeacherHomeSummary? _summary;
  String? _errorMessage;

  TeacherHomeStatus get status => _status;
  TeacherHomeSummary? get summary => _summary;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TeacherHomeStatus.loading;
  bool get hasNoHomeroomClass =>
      _status == TeacherHomeStatus.success &&
      (_summary?.homeroomClasses.isEmpty ?? true);
  bool get hasNoTeachingAssignment =>
      _status == TeacherHomeStatus.success &&
      (_summary?.teachingAssignments.isEmpty ?? true);

  Future<void> loadSummary() async {
    if (isLoading) {
      return;
    }

    _status = TeacherHomeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _teacherRepository.getHomeSummary();
      _status = TeacherHomeStatus.success;
    } on ApiException catch (error) {
      _status = TeacherHomeStatus.error;
      _errorMessage = _mapApiError(error);
    } catch (_) {
      _status = TeacherHomeStatus.error;
      _errorMessage = 'Đã xảy ra lỗi khi tải thông tin giáo viên.';
    }
    notifyListeners();
  }

  String _mapApiError(ApiException error) {
    return switch (error.code) {
      'AUTH_SESSION_MISSING' =>
        'Phiên đăng nhập không tồn tại. Vui lòng đăng nhập lại.',
      'NETWORK_TIMEOUT' => 'Kết nối quá thời gian. Vui lòng thử lại.',
      'NETWORK_ERROR' =>
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.',
      'FORBIDDEN' => 'Bạn không có quyền xem thông tin giáo viên.',
      _ => error.message,
    };
  }
}
