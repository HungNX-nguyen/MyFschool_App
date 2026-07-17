import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/teacher_communication.dart';
import '../../domain/repositories/teacher_communication_repository.dart';

enum TeacherCommunicationPageStatus { idle, loading, ready, error }

enum TeacherCommunicationTab { notification, event }

class TeacherCommunicationController extends ChangeNotifier {
  TeacherCommunicationController(this._repository);

  static const noClassMessage = 'Bạn chưa được phân công lớp.';

  final TeacherCommunicationRepository _repository;

  TeacherCommunicationPageStatus _status = TeacherCommunicationPageStatus.idle;
  TeacherCommunicationTab _selectedTab = TeacherCommunicationTab.notification;
  List<ActiveHomeroomClass> _classes = const <ActiveHomeroomClass>[];
  ActiveHomeroomClass? _selectedClass;
  String? _errorMessage;
  String? _actionErrorMessage;
  String? _successMessage;
  bool _isSubmitting = false;
  int _requestVersion = 0;

  TeacherCommunicationPageStatus get status => _status;
  TeacherCommunicationTab get selectedTab => _selectedTab;
  List<ActiveHomeroomClass> get classes => _classes;
  ActiveHomeroomClass? get selectedClass => _selectedClass;
  String? get errorMessage => _errorMessage;
  String? get actionErrorMessage => _actionErrorMessage;
  String? get successMessage => _successMessage;
  bool get isSubmitting => _isSubmitting;
  bool get hasNoClasses =>
      _status == TeacherCommunicationPageStatus.ready && _classes.isEmpty;

  Future<void> loadInitial() async {
    final requestVersion = ++_requestVersion;
    _status = TeacherCommunicationPageStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedClasses = await _repository.getActiveHomeroomClasses();
      if (requestVersion != _requestVersion) {
        return;
      }
      _classes = loadedClasses;
      final selectedId = _selectedClass?.classId;
      _selectedClass = _classes.isEmpty
          ? null
          : _classes.firstWhere(
              (schoolClass) => schoolClass.classId == selectedId,
              orElse: () => _classes.first,
            );
      _status = TeacherCommunicationPageStatus.ready;
      notifyListeners();
    } on ApiException catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = TeacherCommunicationPageStatus.error;
      _errorMessage = _mapApiError(error);
      notifyListeners();
    } catch (_) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = TeacherCommunicationPageStatus.error;
      _errorMessage = 'Đã xảy ra lỗi khi tải lớp chủ nhiệm.';
      notifyListeners();
    }
  }

  Future<void> retry() => loadInitial();

  void selectClass(int classId) {
    final matches = _classes.where((item) => item.classId == classId);
    if (matches.isEmpty || _selectedClass?.classId == classId) {
      return;
    }
    _selectedClass = matches.first;
    clearFeedback(notify: false);
    notifyListeners();
  }

  void selectTab(TeacherCommunicationTab tab) {
    if (_selectedTab == tab) {
      return;
    }
    _selectedTab = tab;
    clearFeedback(notify: false);
    notifyListeners();
  }

  Future<bool> sendClassNotification({
    required String title,
    required String content,
    required ClassNotificationAudience audience,
  }) async {
    final schoolClass = _selectedClass;
    if (schoolClass == null || _isSubmitting) {
      _actionErrorMessage = noClassMessage;
      notifyListeners();
      return false;
    }

    _beginSubmission();
    try {
      final result = await _repository.sendClassNotification(
        classId: schoolClass.classId,
        title: title.trim(),
        content: content.trim(),
        audience: audience,
      );
      _successMessage =
          'Đã gửi thông báo đến ${result.recipientCount} tài khoản.';
      return true;
    } on ApiException catch (error) {
      _actionErrorMessage = _mapApiError(error);
      return false;
    } catch (_) {
      _actionErrorMessage =
          'Không thể gửi thông báo lúc này. Vui lòng thử lại.';
      return false;
    } finally {
      _finishSubmission();
    }
  }

  Future<bool> createClassEvent(CreateTeacherClassEvent event) async {
    final schoolClass = _selectedClass;
    if (schoolClass == null || _isSubmitting) {
      _actionErrorMessage = noClassMessage;
      notifyListeners();
      return false;
    }

    _beginSubmission();
    try {
      final result = await _repository.createClassEvent(
        classId: schoolClass.classId,
        event: event,
      );
      _successMessage = result.status == TeacherClassEventStatus.published
          ? 'Đã phát hành sự kiện lớp.'
          : 'Đã lưu bản nháp sự kiện.';
      return true;
    } on ApiException catch (error) {
      _actionErrorMessage = _mapApiError(error);
      return false;
    } catch (_) {
      _actionErrorMessage = 'Không thể tạo sự kiện lúc này. Vui lòng thử lại.';
      return false;
    } finally {
      _finishSubmission();
    }
  }

  void clearFeedback({bool notify = true}) {
    _actionErrorMessage = null;
    _successMessage = null;
    if (notify) {
      notifyListeners();
    }
  }

  void _beginSubmission() {
    _isSubmitting = true;
    clearFeedback(notify: false);
    notifyListeners();
  }

  void _finishSubmission() {
    _isSubmitting = false;
    notifyListeners();
  }

  String _mapApiError(ApiException error) {
    return switch (error.code) {
      'AUTH_SESSION_MISSING' =>
        'Phiên đăng nhập không tồn tại. Vui lòng đăng nhập lại.',
      'NETWORK_TIMEOUT' => 'Kết nối quá thời gian. Vui lòng thử lại.',
      'NETWORK_ERROR' =>
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.',
      'FORBIDDEN' => 'Bạn không phải giáo viên chủ nhiệm của lớp này.',
      'BUSINESS_RULE_VIOLATION' => error.message,
      _ => error.message,
    };
  }
}
