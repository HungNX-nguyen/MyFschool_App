import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/teacher_timetable_week.dart';
import '../../domain/entities/timetable_week.dart';
import '../../domain/repositories/timetable_repository.dart';

enum TimetableAudience { parent, student, teacher }

enum TimetableStatus { idle, loading, success, error }

class TimetableController extends ChangeNotifier {
  TimetableController(
    this._repository, {
    required this.audience,
    this.studentId,
    this.semesterId,
    DateTime? initialDate,
  }) : assert(
         audience != TimetableAudience.parent || studentId != null,
         'studentId is required for Parent timetable',
       ),
       _requestedWeekStart = _normalizeWeekStart(initialDate ?? DateTime.now()),
       _selectedDayOfWeek = (initialDate ?? DateTime.now()).weekday;

  final TimetableRepository _repository;
  final TimetableAudience audience;
  final int? studentId;
  final int? semesterId;

  TimetableStatus _status = TimetableStatus.idle;
  TimetableWeek? _week;
  TeacherTimetableWeek? _teacherWeek;
  late DateTime _requestedWeekStart;
  int _selectedDayOfWeek;
  String? _errorMessage;
  int _requestVersion = 0;

  TimetableStatus get status => _status;
  TimetableWeek? get week => _week;
  TeacherTimetableWeek? get teacherWeek => _teacherWeek;
  DateTime get requestedWeekStart => _requestedWeekStart;
  int get selectedDayOfWeek => _selectedDayOfWeek;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TimetableStatus.loading;

  TimetableDay? get selectedDay {
    final days = audience == TimetableAudience.teacher
        ? _teacherWeek?.days
        : _week?.days;
    if (days == null) {
      return null;
    }
    for (final day in days) {
      if (day.dayOfWeek == _selectedDayOfWeek) {
        return day;
      }
    }
    return null;
  }

  Future<void> loadInitial() {
    return loadWeek(_requestedWeekStart);
  }

  Future<void> previousWeek() {
    return loadWeek(_requestedWeekStart.subtract(const Duration(days: 7)));
  }

  Future<void> nextWeek() {
    return loadWeek(_requestedWeekStart.add(const Duration(days: 7)));
  }

  Future<void> retry() {
    return loadWeek(_requestedWeekStart);
  }

  Future<void> loadWeek(DateTime date) async {
    final weekStart = _normalizeWeekStart(date);
    final requestVersion = ++_requestVersion;

    _requestedWeekStart = weekStart;
    _status = TimetableStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedWeek = switch (audience) {
        TimetableAudience.parent => await _repository.getParentStudentTimetable(
          studentId: studentId!,
          weekStart: weekStart,
          semesterId: semesterId,
        ),
        TimetableAudience.student => await _repository.getStudentTimetable(
          weekStart: weekStart,
          semesterId: semesterId,
        ),
        TimetableAudience.teacher => await _repository.getTeacherTimetable(
          weekStart: weekStart,
          semesterId: semesterId,
        ),
      };

      if (requestVersion != _requestVersion) {
        return;
      }

      final loadedDays = switch (loadedWeek) {
        TimetableWeek week => week.days,
        TeacherTimetableWeek week => week.days,
        _ => throw StateError('Unsupported timetable response'),
      };
      if (loadedWeek is TimetableWeek) {
        _week = loadedWeek;
        _teacherWeek = null;
      } else if (loadedWeek is TeacherTimetableWeek) {
        _teacherWeek = loadedWeek;
        _week = null;
      }
      _status = TimetableStatus.success;
      _errorMessage = null;
      _ensureSelectedDayExists(loadedDays);
      notifyListeners();
    } on ApiException catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = TimetableStatus.error;
      _errorMessage = _mapApiError(error);
      notifyListeners();
    } catch (_) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = TimetableStatus.error;
      _errorMessage = 'Đã xảy ra lỗi khi tải thời khóa biểu.';
      notifyListeners();
    }
  }

  bool selectDay(int dayOfWeek) {
    if (dayOfWeek < DateTime.monday || dayOfWeek > DateTime.sunday) {
      return false;
    }
    if (_selectedDayOfWeek == dayOfWeek) {
      return true;
    }
    _selectedDayOfWeek = dayOfWeek;
    notifyListeners();
    return true;
  }

  void _ensureSelectedDayExists(List<TimetableDay> days) {
    final exists = days.any((day) => day.dayOfWeek == _selectedDayOfWeek);
    if (!exists && days.isNotEmpty) {
      _selectedDayOfWeek = days.first.dayOfWeek;
    }
  }

  String _mapApiError(ApiException error) {
    return switch (error.code) {
      'AUTH_SESSION_MISSING' =>
        'Phiên đăng nhập không tồn tại. Vui lòng đăng nhập lại.',
      'NETWORK_TIMEOUT' => 'Kết nối quá thời gian. Vui lòng thử lại.',
      'NETWORK_ERROR' =>
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      'FORBIDDEN' => 'Bạn không có quyền xem thời khóa biểu này.',
      'RESOURCE_NOT_FOUND' => error.message,
      _ => error.message,
    };
  }

  static DateTime _normalizeWeekStart(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return normalizedDate.subtract(Duration(days: normalizedDate.weekday - 1));
  }
}
