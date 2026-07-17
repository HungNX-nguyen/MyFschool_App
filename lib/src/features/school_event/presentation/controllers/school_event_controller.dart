import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/school_event.dart';
import '../../domain/repositories/school_event_repository.dart';

enum SchoolEventAudience { parent, student }

enum SchoolEventStatus { idle, loading, success, error }

class SchoolEventController extends ChangeNotifier {
  SchoolEventController(
    this._repository, {
    required this.audience,
    this.studentId,
    SchoolEventTimeRange initialTimeRange = SchoolEventTimeRange.upcoming,
    SchoolEventViewScope initialScope = SchoolEventViewScope.all,
  }) : assert(
         audience != SchoolEventAudience.parent || studentId != null,
         'studentId is required for Parent school events',
       ),
       _selectedTimeRange = initialTimeRange,
       _selectedScope = initialScope;

  final SchoolEventRepository _repository;
  final SchoolEventAudience audience;
  final int? studentId;

  SchoolEventStatus _status = SchoolEventStatus.idle;
  SchoolEventFeed? _feed;
  SchoolEventTimeRange _selectedTimeRange;
  SchoolEventViewScope _selectedScope;
  String? _errorMessage;
  int _requestVersion = 0;

  SchoolEventStatus get status => _status;
  SchoolEventFeed? get feed => _feed;
  SchoolEventTimeRange get selectedTimeRange => _selectedTimeRange;
  SchoolEventViewScope get selectedScope => _selectedScope;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == SchoolEventStatus.loading;
  bool get hasNoEvents =>
      _status == SchoolEventStatus.success && events.isEmpty;
  List<SchoolEvent> get events => _feed?.items ?? const <SchoolEvent>[];

  Future<void> loadInitial() => _loadEvents();

  Future<void> retry() => _loadEvents();

  Future<void> selectTimeRange(SchoolEventTimeRange timeRange) {
    if (_selectedTimeRange == timeRange && _feed != null) {
      return Future<void>.value();
    }
    _selectedTimeRange = timeRange;
    return _loadEvents();
  }

  Future<void> selectScope(SchoolEventViewScope scope) {
    if (_selectedScope == scope && _feed != null) {
      return Future<void>.value();
    }
    _selectedScope = scope;
    return _loadEvents();
  }

  Future<void> _loadEvents() async {
    final requestVersion = ++_requestVersion;
    final requestedTimeRange = _selectedTimeRange;
    final requestedScope = _selectedScope;

    _status = SchoolEventStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedFeed = switch (audience) {
        SchoolEventAudience.parent => await _repository.getParentStudentEvents(
          studentId: studentId!,
          timeRange: requestedTimeRange,
          scope: requestedScope,
        ),
        SchoolEventAudience.student => await _repository.getStudentEvents(
          timeRange: requestedTimeRange,
          scope: requestedScope,
        ),
      };

      if (requestVersion != _requestVersion) {
        return;
      }

      _feed = loadedFeed;
      _selectedTimeRange = loadedFeed.timeRange;
      _selectedScope = loadedFeed.scope;
      _status = SchoolEventStatus.success;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = SchoolEventStatus.error;
      _errorMessage = _mapApiError(error);
      notifyListeners();
    } catch (_) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = SchoolEventStatus.error;
      _errorMessage = 'Đã xảy ra lỗi khi tải danh sách sự kiện.';
      notifyListeners();
    }
  }

  String _mapApiError(ApiException error) {
    return switch (error.code) {
      'AUTH_SESSION_MISSING' =>
        'Phiên đăng nhập không tồn tại. Vui lòng đăng nhập lại.',
      'NETWORK_TIMEOUT' => 'Kết nối quá thời gian. Vui lòng thử lại.',
      'NETWORK_ERROR' =>
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      'FORBIDDEN' => 'Bạn không có quyền xem danh sách sự kiện này.',
      'RESOURCE_NOT_FOUND' => error.message,
      _ => error.message,
    };
  }
}
