import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/leave_request.dart';
import '../../domain/repositories/leave_request_repository.dart';

enum ParentLeaveRequestStatus { idle, loading, success, error }

class ParentLeaveRequestController extends ChangeNotifier {
  ParentLeaveRequestController(this._repository, {required this.studentId});

  final LeaveRequestRepository _repository;
  final int studentId;

  ParentLeaveRequestStatus _status = ParentLeaveRequestStatus.idle;
  List<LeaveRequest> _requests = const <LeaveRequest>[];
  String? _errorMessage;
  String? _actionErrorMessage;
  bool _isSubmitting = false;
  int? _processingRequestId;
  int _requestVersion = 0;

  ParentLeaveRequestStatus get status => _status;
  List<LeaveRequest> get requests => _requests;
  String? get errorMessage => _errorMessage;
  String? get actionErrorMessage => _actionErrorMessage;
  bool get isSubmitting => _isSubmitting;
  int? get processingRequestId => _processingRequestId;
  bool get isLoading => _status == ParentLeaveRequestStatus.loading;

  Future<void> loadInitial() => loadRequests();

  Future<void> retry() => loadRequests();

  Future<void> loadRequests() async {
    final requestVersion = ++_requestVersion;
    _status = ParentLeaveRequestStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedRequests = await _repository.getParentLeaveRequests(
        studentId: studentId,
      );
      if (requestVersion != _requestVersion) {
        return;
      }
      _requests = loadedRequests;
      _status = ParentLeaveRequestStatus.success;
      notifyListeners();
    } on ApiException catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = ParentLeaveRequestStatus.error;
      _errorMessage = _mapApiError(error);
      notifyListeners();
    } catch (_) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = ParentLeaveRequestStatus.error;
      _errorMessage = 'Đã xảy ra lỗi khi tải lịch sử đơn.';
      notifyListeners();
    }
  }

  Future<bool> createLeaveRequest({
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    if (_isSubmitting) {
      return false;
    }
    _isSubmitting = true;
    _actionErrorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createParentLeaveRequest(
        studentId: studentId,
        fromDate: fromDate,
        toDate: toDate,
        reason: reason.trim(),
      );
      _requests = <LeaveRequest>[
        created,
        ..._requests.where((request) => request.id != created.id),
      ];
      _status = ParentLeaveRequestStatus.success;
      return true;
    } on ApiException catch (error) {
      _actionErrorMessage = _mapApiError(error);
      return false;
    } catch (_) {
      _actionErrorMessage = 'Không thể gửi đơn lúc này. Vui lòng thử lại.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> cancelLeaveRequest(int leaveRequestId) async {
    if (_processingRequestId != null) {
      return false;
    }
    _processingRequestId = leaveRequestId;
    _actionErrorMessage = null;
    notifyListeners();

    try {
      final cancelled = await _repository.cancelParentLeaveRequest(
        leaveRequestId,
      );
      _requests = _requests
          .map((request) => request.id == cancelled.id ? cancelled : request)
          .toList(growable: false);
      return true;
    } on ApiException catch (error) {
      _actionErrorMessage = _mapApiError(error);
      return false;
    } catch (_) {
      _actionErrorMessage = 'Không thể hủy đơn lúc này. Vui lòng thử lại.';
      return false;
    } finally {
      _processingRequestId = null;
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
      'LEAVE_REQUEST_DATE_OVERLAP' =>
        'Khoảng ngày này trùng với đơn đang chờ hoặc đã duyệt.',
      'LEAVE_REQUEST_ALREADY_PROCESSED' =>
        'Đơn đã được xử lý nên không thể hủy.',
      'FORBIDDEN' => 'Bạn không có quyền thao tác với đơn này.',
      _ => error.message,
    };
  }
}
