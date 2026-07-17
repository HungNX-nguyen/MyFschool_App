import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../timetable/domain/entities/timetable_week.dart';
import '../../domain/entities/homeroom_class.dart';
import '../../domain/entities/homeroom_timetable.dart';
import '../../domain/repositories/homeroom_repository.dart';

enum HomeroomPageStatus { idle, loading, success, error }

enum HomeroomTab { roster, timetable }

class HomeroomController extends ChangeNotifier {
  HomeroomController(this._repository, {DateTime? initialDate})
    : _referenceDate = _normalizeDate(initialDate ?? DateTime.now()),
      _requestedWeekStart = _normalizeWeekStart(initialDate ?? DateTime.now()),
      _selectedDayOfWeek = (initialDate ?? DateTime.now()).weekday;

  static const noClassMessage = 'Bạn chưa được phân công lớp.';
  static const noSemesterMessage = 'Lớp chưa có học kỳ để xem lịch.';

  final HomeroomRepository _repository;
  final DateTime _referenceDate;

  HomeroomPageStatus _status = HomeroomPageStatus.idle;
  HomeroomPageStatus _rosterStatus = HomeroomPageStatus.idle;
  HomeroomTab _selectedTab = HomeroomTab.roster;
  List<HomeroomClassSummary> _classes = const <HomeroomClassSummary>[];
  HomeroomClassSummary? _selectedClass;
  HomeroomClassRoster? _roster;
  HomeroomTimetableWeek? _timetable;
  HomeroomSemester? _selectedSemester;
  DateTime _requestedWeekStart;
  int _selectedDayOfWeek;
  int? _selectedStudyGroupId;
  String? _errorMessage;
  String? _rosterErrorMessage;
  String? _timetableErrorMessage;
  bool _isTimetableLoading = false;
  int _pageRequestVersion = 0;
  int _rosterRequestVersion = 0;
  int _timetableRequestVersion = 0;

  HomeroomPageStatus get status => _status;
  HomeroomPageStatus get rosterStatus => _rosterStatus;
  HomeroomTab get selectedTab => _selectedTab;
  List<HomeroomClassSummary> get classes => _classes;
  HomeroomClassSummary? get selectedClass => _selectedClass;
  HomeroomClassRoster? get roster => _roster;
  HomeroomTimetableWeek? get timetable => _timetable;
  HomeroomSemester? get selectedSemester => _selectedSemester;
  DateTime get requestedWeekStart => _requestedWeekStart;
  int get selectedDayOfWeek => _selectedDayOfWeek;
  int? get selectedStudyGroupId => _selectedStudyGroupId;
  String? get errorMessage => _errorMessage;
  String? get rosterErrorMessage => _rosterErrorMessage;
  String? get timetableErrorMessage => _timetableErrorMessage;
  bool get isLoading => _status == HomeroomPageStatus.loading;
  bool get isRosterLoading => _rosterStatus == HomeroomPageStatus.loading;
  bool get isTimetableLoading => _isTimetableLoading;
  bool get hasNoClasses =>
      _status == HomeroomPageStatus.success && _classes.isEmpty;

  List<HomeroomSemester> get availableSemesters =>
      _selectedClass?.semesters ?? const <HomeroomSemester>[];

  List<HomeroomStudent> get students =>
      _roster?.students ?? const <HomeroomStudent>[];

  List<HomeroomStudyGroup> get availableStudyGroups =>
      _timetable?.availableStudyGroups ?? const <HomeroomStudyGroup>[];

  bool get canGoPreviousWeek {
    final semester = _selectedSemester;
    return semester != null &&
        _weekOverlapsSemester(
          _requestedWeekStart.subtract(const Duration(days: 7)),
          semester,
        );
  }

  bool get canGoNextWeek {
    final semester = _selectedSemester;
    return semester != null &&
        _weekOverlapsSemester(
          _requestedWeekStart.add(const Duration(days: 7)),
          semester,
        );
  }

  TimetableDay? get selectedDay {
    final days = _timetable?.days;
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

  Future<void> loadInitial() async {
    final requestVersion = ++_pageRequestVersion;
    _cancelSelectedClassRequests();
    _status = HomeroomPageStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedClasses = await _repository.getHomeroomClasses();
      if (requestVersion != _pageRequestVersion) {
        return;
      }

      _classes = loadedClasses;
      if (_classes.isEmpty) {
        _clearSelectedClassData();
        _status = HomeroomPageStatus.success;
        notifyListeners();
        return;
      }

      final selectedClassId = _selectedClass?.classId;
      _selectedClass = _classes.firstWhere(
        (schoolClass) => schoolClass.classId == selectedClassId,
        orElse: () => _classes.first,
      );
      _prepareSelectedClassData();
      _status = HomeroomPageStatus.success;
      notifyListeners();
      await _loadRoster();
    } on ApiException catch (error) {
      if (requestVersion != _pageRequestVersion) {
        return;
      }
      _setPageError(_mapApiError(error));
    } catch (_) {
      if (requestVersion != _pageRequestVersion) {
        return;
      }
      _setPageError('Đã xảy ra lỗi khi tải thông tin lớp chủ nhiệm.');
    }
  }

  Future<void> retry() {
    if (_status == HomeroomPageStatus.error || _selectedClass == null) {
      return loadInitial();
    }
    return retryRoster();
  }

  Future<void> retryRoster() {
    return _loadRoster();
  }

  Future<void> selectTab(HomeroomTab tab) async {
    final changed = _selectedTab != tab;
    _selectedTab = tab;
    if (changed) {
      notifyListeners();
    }
    if (tab == HomeroomTab.timetable &&
        _timetable == null &&
        !_isTimetableLoading) {
      await _loadTimetable(_requestedWeekStart);
    }
  }

  Future<void> selectClass(int classId) async {
    final matches = _classes.where((item) => item.classId == classId);
    if (matches.isEmpty || _selectedClass?.classId == classId) {
      return;
    }

    _cancelSelectedClassRequests();
    _selectedClass = matches.first;
    _prepareSelectedClassData();
    notifyListeners();

    final requests = <Future<void>>[_loadRoster()];
    if (_selectedTab == HomeroomTab.timetable) {
      requests.add(_loadTimetable(_requestedWeekStart));
    }
    await Future.wait(requests);
  }

  Future<void> selectSemester(int semesterId) {
    HomeroomSemester? selected;
    for (final semester in availableSemesters) {
      if (semester.semesterId == semesterId) {
        selected = semester;
        break;
      }
    }
    if (selected == null || _selectedSemester?.semesterId == semesterId) {
      return Future<void>.value();
    }

    ++_timetableRequestVersion;
    _selectedSemester = selected;
    _selectedStudyGroupId = null;
    _timetable = null;
    _timetableErrorMessage = null;
    _setInitialWeekForSemester(selected);
    notifyListeners();
    return _loadTimetable(_requestedWeekStart);
  }

  Future<void> selectDate(DateTime date) {
    final semester = _selectedSemester;
    if (semester == null) {
      _setTimetableError(noSemesterMessage);
      return Future<void>.value();
    }
    if (!semester.containsDate(date)) {
      _setTimetableError('Ngày được chọn nằm ngoài học kỳ.');
      return Future<void>.value();
    }

    _selectedDayOfWeek = date.weekday;
    return _loadTimetable(date);
  }

  Future<void> previousWeek() {
    if (!canGoPreviousWeek) {
      return Future<void>.value();
    }
    return _loadTimetable(
      _requestedWeekStart.subtract(const Duration(days: 7)),
    );
  }

  Future<void> nextWeek() {
    if (!canGoNextWeek) {
      return Future<void>.value();
    }
    return _loadTimetable(_requestedWeekStart.add(const Duration(days: 7)));
  }

  Future<void> retryTimetable() {
    return _loadTimetable(_requestedWeekStart);
  }

  Future<void> selectStudyGroup(int? studyGroupId) {
    if (_selectedStudyGroupId == studyGroupId && _timetable != null) {
      return Future<void>.value();
    }
    if (studyGroupId != null && !_isAvailableStudyGroup(studyGroupId)) {
      return Future<void>.value();
    }
    _selectedStudyGroupId = studyGroupId;
    return _loadTimetable(_requestedWeekStart);
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

  Future<void> _loadRoster() async {
    final schoolClass = _selectedClass;
    if (schoolClass == null) {
      return;
    }

    final requestVersion = ++_rosterRequestVersion;
    _rosterStatus = HomeroomPageStatus.loading;
    _rosterErrorMessage = null;
    notifyListeners();

    try {
      final loadedRoster = await _repository.getClassRoster(
        schoolClass.classId,
      );
      if (requestVersion != _rosterRequestVersion) {
        return;
      }
      _roster = loadedRoster;
      _rosterStatus = HomeroomPageStatus.success;
    } on ApiException catch (error) {
      if (requestVersion != _rosterRequestVersion) {
        return;
      }
      _rosterStatus = HomeroomPageStatus.error;
      _rosterErrorMessage = _mapApiError(error);
    } catch (_) {
      if (requestVersion != _rosterRequestVersion) {
        return;
      }
      _rosterStatus = HomeroomPageStatus.error;
      _rosterErrorMessage = 'Đã xảy ra lỗi khi tải danh sách lớp.';
    } finally {
      if (requestVersion == _rosterRequestVersion) {
        notifyListeners();
      }
    }
  }

  Future<void> _loadTimetable(DateTime date) async {
    final schoolClass = _selectedClass;
    final semester = _selectedSemester;
    if (schoolClass == null) {
      return;
    }
    if (semester == null) {
      _setTimetableError(noSemesterMessage);
      return;
    }

    final weekStart = _normalizeWeekStart(date);
    if (!_weekOverlapsSemester(weekStart, semester)) {
      _setTimetableError('Tuần được chọn nằm ngoài học kỳ.');
      return;
    }

    final requestVersion = ++_timetableRequestVersion;
    _requestedWeekStart = weekStart;
    _isTimetableLoading = true;
    _timetableErrorMessage = null;
    notifyListeners();

    try {
      final loadedTimetable = await _repository.getClassTimetable(
        classId: schoolClass.classId,
        weekStart: weekStart,
        semesterId: semester.semesterId,
        studyGroupId: _selectedStudyGroupId,
      );
      if (requestVersion != _timetableRequestVersion) {
        return;
      }

      _timetable = loadedTimetable;
      _requestedWeekStart = loadedTimetable.weekStart;
      _selectedStudyGroupId = loadedTimetable.selectedStudyGroupId;
      _ensureSelectedDayExists(loadedTimetable.days);
      _timetableErrorMessage = null;
    } on ApiException catch (error) {
      if (requestVersion != _timetableRequestVersion) {
        return;
      }
      _timetableErrorMessage = _mapApiError(error);
    } catch (_) {
      if (requestVersion != _timetableRequestVersion) {
        return;
      }
      _timetableErrorMessage = 'Đã xảy ra lỗi khi tải lịch học của lớp.';
    } finally {
      if (requestVersion == _timetableRequestVersion) {
        _isTimetableLoading = false;
        notifyListeners();
      }
    }
  }

  void _prepareSelectedClassData() {
    _roster = null;
    _rosterStatus = HomeroomPageStatus.idle;
    _rosterErrorMessage = null;
    _timetable = null;
    _selectedStudyGroupId = null;
    _timetableErrorMessage = null;
    _selectInitialSemester();
  }

  void _selectInitialSemester() {
    final semesters = [...availableSemesters]
      ..sort((left, right) => left.startDate.compareTo(right.startDate));
    if (semesters.isEmpty) {
      _selectedSemester = null;
      _requestedWeekStart = _normalizeWeekStart(_referenceDate);
      _selectedDayOfWeek = _referenceDate.weekday;
      return;
    }

    HomeroomSemester? selected;
    for (final semester in semesters) {
      if (semester.containsDate(_referenceDate)) {
        selected = semester;
        break;
      }
    }
    if (selected == null) {
      for (final semester in semesters) {
        if (semester.startDate.isAfter(_referenceDate)) {
          selected = semester;
          break;
        }
      }
    }
    selected ??= semesters.last;
    _selectedSemester = selected;
    _setInitialWeekForSemester(selected);
  }

  void _setInitialWeekForSemester(HomeroomSemester semester) {
    final DateTime anchorDate;
    if (semester.containsDate(_referenceDate)) {
      anchorDate = _referenceDate;
    } else if (_referenceDate.isBefore(semester.startDate)) {
      anchorDate = semester.startDate;
    } else {
      anchorDate = semester.endDate;
    }
    _requestedWeekStart = _normalizeWeekStart(anchorDate);
    _selectedDayOfWeek = anchorDate.weekday;
  }

  void _clearSelectedClassData() {
    _selectedClass = null;
    _roster = null;
    _rosterStatus = HomeroomPageStatus.idle;
    _rosterErrorMessage = null;
    _timetable = null;
    _selectedSemester = null;
    _selectedStudyGroupId = null;
    _timetableErrorMessage = null;
  }

  void _cancelSelectedClassRequests() {
    ++_rosterRequestVersion;
    ++_timetableRequestVersion;
    _isTimetableLoading = false;
  }

  void _setPageError(String message) {
    _status = HomeroomPageStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _setTimetableError(String message) {
    _isTimetableLoading = false;
    _timetableErrorMessage = message;
    notifyListeners();
  }

  bool _isAvailableStudyGroup(int studyGroupId) {
    return availableStudyGroups.any(
      (group) => group.studyGroupId == studyGroupId,
    );
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
      'FORBIDDEN' => 'Bạn không phải giáo viên chủ nhiệm của lớp này.',
      'RESOURCE_NOT_FOUND' => error.message,
      _ => error.message,
    };
  }

  static bool _weekOverlapsSemester(DateTime date, HomeroomSemester semester) {
    final weekStart = _normalizeWeekStart(date);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final semesterStart = _normalizeDate(semester.startDate);
    final semesterEnd = _normalizeDate(semester.endDate);
    return !weekEnd.isBefore(semesterStart) && !weekStart.isAfter(semesterEnd);
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime _normalizeWeekStart(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return normalizedDate.subtract(Duration(days: normalizedDate.weekday - 1));
  }
}
