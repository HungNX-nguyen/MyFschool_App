import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/homeroom_class.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/repositories/leave_request_repository.dart';

enum TeacherLeaveRequestPageStatus { idle, loading, success, error }

class TeacherLeaveRequestController extends ChangeNotifier {
  TeacherLeaveRequestController(this._repository);

  final LeaveRequestRepository _repository;

  TeacherLeaveRequestPageStatus _status = TeacherLeaveRequestPageStatus.idle;
  List<HomeroomClass> _classes = const <HomeroomClass>[];
  List<LeaveRequest> _requests = const <LeaveRequest>[];
  HomeroomClass? _selectedClass;
  LeaveRequestStatus _selectedStatus = LeaveRequestStatus.pending;
  String? _errorMessage;
  String? _actionErrorMessage;
  int? _processingRequestId;
  int _requestVersion = 0;

  TeacherLeaveRequestPageStatus get status => _status;
  List<HomeroomClass> get classes => _classes;
  List<LeaveRequest> get requests => _requests;
  HomeroomClass? get selectedClass => _selectedClass;
  LeaveRequestStatus get selectedStatus => _selectedStatus;
  String? get errorMessage => _errorMessage;
  String? get actionErrorMessage => _actionErrorMessage;
  int? get processingRequestId => _processingRequestId;
  bool get isLoading => _status == TeacherLeaveRequestPageStatus.loading;

  Future<void> loadInitial() async {
    final requestVersion = ++_requestVersion;
    _status = TeacherLeaveRequestPageStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedClasses = await _repository.getTeacherHomeroomClasses();
      if (requestVersion != _requestVersion) {
        return;
      }
      _classes = loadedClasses;
      if (_classes.isEmpty) {
        _selectedClass = null;
        _requests = const <LeaveRequest>[];
        _status = TeacherLeaveRequestPageStatus.success;
        notifyListeners();
        return;
      }

      final selectedId = _selectedClass?.classId;
      _selectedClass = _classes.firstWhere(
        (schoolClass) => schoolClass.classId == selectedId,
        orElse: () => _classes.first,
      );
      final loadedRequests = await _repository.getTeacherLeaveRequests(
        classId: _selectedClass!.classId,
        status: _selectedStatus,
      );
      if (requestVersion != _requestVersion) {
        return;
      }
      _requests = loadedRequests;
      _status = TeacherLeaveRequestPageStatus.success;
      notifyListeners();
    } on ApiException catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = TeacherLeaveRequestPageStatus.error;
      _errorMessage = _mapApiError(error);
      notifyListeners();
    } catch (_) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = TeacherLeaveRequestPageStatus.error;
      _errorMessage = 'Đã xảy ra lỗi khi tải danh sách đơn.';
      notifyListeners();
    }
  }

  Future<void> retry() {
    if (_selectedClass == null) {
      return loadInitial();
    }
    return _loadRequests();
  }

  Future<void> selectClass(int classId) {
    final schoolClass = _classes.where((item) => item.classId == classId);
    if (schoolClass.isEmpty || _selectedClass?.classId == classId) {
      return Future<void>.value();
    }
    _selectedClass = schoolClass.first;
    return _loadRequests();
  }

  Future<void> selectStatus(LeaveRequestStatus status) {
    if (_selectedStatus == status) {
      return Future<void>.value();
    }
    _selectedStatus = status;
    if (_selectedClass == null) {
      notifyListeners();
      return Future<void>.value();
    }
    return _loadRequests();
  }

  Future<bool> reviewLeaveRequest({
    required int leaveRequestId,
    required LeaveRequestDecision decision,
    String? reviewNote,
  }) async {
    if (_processingRequestId != null) {
      return false;
    }
    if (decision == LeaveRequestDecision.rejected &&
        (reviewNote == null || reviewNote.trim().isEmpty)) {
      _actionErrorMessage = 'Vui lòng nhập lý do từ chối.';
      notifyListeners();
      return false;
    }

    _processingRequestId = leaveRequestId;
    _actionErrorMessage = null;
    notifyListeners();

    try {
      final reviewed = await _repository.reviewTeacherLeaveRequest(
        leaveRequestId: leaveRequestId,
        decision: decision,
        reviewNote: reviewNote?.trim(),
      );
      if (reviewed.status == _selectedStatus) {
        _requests = _requests
            .map((request) => request.id == reviewed.id ? reviewed : request)
            .toList(growable: false);
      } else {
        _requests = _requests
            .where((request) => request.id != reviewed.id)
            .toList(growable: false);
      }
      return true;
    } on ApiException catch (error) {
      _actionErrorMessage = _mapApiError(error);
      return false;
    } catch (_) {
      _actionErrorMessage = 'Không thể xử lý đơn lúc này. Vui lòng thử lại.';
      return false;
    } finally {
      _processingRequestId = null;
      notifyListeners();
    }
  }

  Future<void> _loadRequests() async {
    final schoolClass = _selectedClass;
    if (schoolClass == null) {
      _requests = const <LeaveRequest>[];
      _status = TeacherLeaveRequestPageStatus.success;
      notifyListeners();
      return;
    }

    final requestVersion = ++_requestVersion;
    _status = TeacherLeaveRequestPageStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedRequests = await _repository.getTeacherLeaveRequests(
        classId: schoolClass.classId,
        status: _selectedStatus,
      );
      if (requestVersion != _requestVersion) {
        return;
      }
      _requests = loadedRequests;
      _status = TeacherLeaveRequestPageStatus.success;
      notifyListeners();
    } on ApiException catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = TeacherLeaveRequestPageStatus.error;
      _errorMessage = _mapApiError(error);
      notifyListeners();
    } catch (_) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = TeacherLeaveRequestPageStatus.error;
      _errorMessage = 'Đã xảy ra lỗi khi tải danh sách đơn.';
      notifyListeners();
    }
  }

  String _mapApiError(ApiException error) {
    return switch (error.code) {
      'AUTH_SESSION_MISSING' =>
        'Phiên đăng nhập không tồn tại. Vui lòng đăng nhập lại.',
      'NETWORK_TIMEOUT' => 'Kết nối quá thời gian. Vui lòng thử lại.',
      'NETWORK_ERROR' =>
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.',
      'LEAVE_REQUEST_ALREADY_PROCESSED' =>
        'Đơn này đã được giáo viên khác xử lý.',
      'FORBIDDEN' => 'Bạn không phải giáo viên chủ nhiệm của lớp này.',
      _ => error.message,
    };
  }
}
