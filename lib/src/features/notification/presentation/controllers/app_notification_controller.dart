import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../school_event/domain/entities/school_event.dart';
import '../../../school_event/domain/repositories/school_event_repository.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/app_notification_repository.dart';

enum AppNotificationPageStatus { idle, loading, ready, error }

class NotificationOpenResult {
  const NotificationOpenResult({required this.detail, this.schoolEvent});

  final AppNotificationDetail detail;
  final SchoolEvent? schoolEvent;
}

class AppNotificationController extends ChangeNotifier {
  AppNotificationController(this._repository, this._schoolEventRepository);

  static const pageSize = 20;
  static const pollingInterval = Duration(seconds: 30);

  final AppNotificationRepository _repository;
  final SchoolEventRepository _schoolEventRepository;

  AppNotificationPageStatus _status = AppNotificationPageStatus.idle;
  List<AppNotificationItem> _items = const <AppNotificationItem>[];
  int _unreadCount = 0;
  int _page = 0;
  int _totalPages = 0;
  bool _isLoadingMore = false;
  bool _isMarkingAllRead = false;
  int? _openingNotificationId;
  String? _errorMessage;
  String? _actionErrorMessage;
  int _requestVersion = 0;
  Timer? _pollingTimer;
  int _monitorSubscribers = 0;

  AppNotificationPageStatus get status => _status;
  List<AppNotificationItem> get items => _items;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;
  bool get isLoadingMore => _isLoadingMore;
  bool get isMarkingAllRead => _isMarkingAllRead;
  int? get openingNotificationId => _openingNotificationId;
  String? get errorMessage => _errorMessage;
  String? get actionErrorMessage => _actionErrorMessage;
  bool get hasMore => _page + 1 < _totalPages;
  bool get isMonitoring => _pollingTimer != null;

  void startMonitoring() {
    _monitorSubscribers++;
    if (_pollingTimer != null) {
      return;
    }
    unawaited(refreshUnreadCount());
    _pollingTimer = Timer.periodic(
      pollingInterval,
      (_) => unawaited(refreshUnreadCount()),
    );
  }

  void stopMonitoring() {
    if (_monitorSubscribers > 0) {
      _monitorSubscribers--;
    }
    if (_monitorSubscribers > 0) {
      return;
    }
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> loadInitial() async {
    final requestVersion = ++_requestVersion;
    _status = AppNotificationPageStatus.loading;
    _errorMessage = null;
    _actionErrorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getMyNotifications(
        page: 0,
        size: pageSize,
      );
      if (requestVersion != _requestVersion) {
        return;
      }
      _items = result.items;
      _page = result.page;
      _totalPages = result.totalPages;
      _unreadCount = result.unreadCount;
      _status = AppNotificationPageStatus.ready;
      notifyListeners();
    } on ApiException catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = AppNotificationPageStatus.error;
      _errorMessage = _mapApiError(error);
      notifyListeners();
    } catch (_) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = AppNotificationPageStatus.error;
      _errorMessage = 'Không thể tải danh sách thông báo lúc này.';
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) {
      return;
    }
    _isLoadingMore = true;
    notifyListeners();
    try {
      final result = await _repository.getMyNotifications(
        page: _page + 1,
        size: pageSize,
      );
      _items = List<AppNotificationItem>.unmodifiable(<AppNotificationItem>[
        ..._items,
        ...result.items,
      ]);
      _page = result.page;
      _totalPages = result.totalPages;
      _unreadCount = result.unreadCount;
    } on ApiException catch (error) {
      _actionErrorMessage = _mapApiError(error);
    } catch (_) {
      _actionErrorMessage = 'Không thể tải thêm thông báo.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      if (_unreadCount == count) {
        return;
      }
      _unreadCount = count;
      notifyListeners();
    } catch (_) {
      // Polling badge is best-effort; the next foreground refresh retries it.
    }
  }

  Future<NotificationOpenResult?> openNotification(int notificationId) async {
    if (_openingNotificationId != null) {
      return null;
    }
    _openingNotificationId = notificationId;
    _actionErrorMessage = null;
    notifyListeners();
    try {
      final detail = await _repository.markNotificationRead(notificationId);
      _applyReadDetail(detail);

      final target = detail.navigationTarget;
      SchoolEvent? event;
      if (detail.type == AppNotificationType.event &&
          target?.type == 'SCHOOL_EVENT') {
        event = await _schoolEventRepository.getAccessibleEventDetail(
          target!.id,
        );
      }
      return NotificationOpenResult(detail: detail, schoolEvent: event);
    } on ApiException catch (error) {
      _actionErrorMessage = error.code == 'RESOURCE_NOT_FOUND'
          ? 'Sự kiện không còn khả dụng hoặc bạn không có quyền xem.'
          : _mapApiError(error);
      return null;
    } catch (_) {
      _actionErrorMessage = 'Không thể mở thông báo lúc này.';
      return null;
    } finally {
      _openingNotificationId = null;
      notifyListeners();
    }
  }

  Future<bool> markAllRead() async {
    if (_isMarkingAllRead || _unreadCount == 0) {
      return false;
    }
    _isMarkingAllRead = true;
    _actionErrorMessage = null;
    notifyListeners();
    try {
      final result = await _repository.markAllRead();
      final now = DateTime.now();
      _items = List<AppNotificationItem>.unmodifiable(
        _items.map((item) => item.isRead ? item : item.markRead(at: now)),
      );
      _unreadCount = result.unreadCount;
      return true;
    } on ApiException catch (error) {
      _actionErrorMessage = _mapApiError(error);
      return false;
    } catch (_) {
      _actionErrorMessage = 'Không thể đánh dấu tất cả là đã đọc.';
      return false;
    } finally {
      _isMarkingAllRead = false;
      notifyListeners();
    }
  }

  void clearActionError() {
    if (_actionErrorMessage == null) {
      return;
    }
    _actionErrorMessage = null;
    notifyListeners();
  }

  void reset() {
    _monitorSubscribers = 0;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _requestVersion++;
    _status = AppNotificationPageStatus.idle;
    _items = const <AppNotificationItem>[];
    _unreadCount = 0;
    _page = 0;
    _totalPages = 0;
    _isLoadingMore = false;
    _isMarkingAllRead = false;
    _openingNotificationId = null;
    _errorMessage = null;
    _actionErrorMessage = null;
    notifyListeners();
  }

  void _applyReadDetail(AppNotificationDetail detail) {
    final index = _items.indexWhere((item) => item.id == detail.id);
    if (index < 0 || _items[index].isRead) {
      return;
    }
    final updated = List<AppNotificationItem>.of(_items);
    updated[index] = updated[index].markRead(at: detail.readAt);
    _items = List<AppNotificationItem>.unmodifiable(updated);
    if (_unreadCount > 0) {
      _unreadCount--;
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
      _ => error.message,
    };
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
