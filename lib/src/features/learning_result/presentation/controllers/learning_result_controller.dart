import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/learning_result.dart';
import '../../domain/repositories/learning_result_repository.dart';

enum LearningResultAudience { parent, student }

enum LearningResultStatus { idle, loading, success, error }

class LearningResultController extends ChangeNotifier {
  LearningResultController(
    this._repository, {
    required this.audience,
    this.studentId,
    LearningResultPeriod initialPeriod = LearningResultPeriod.annual,
  }) : assert(
         audience != LearningResultAudience.parent || studentId != null,
         'studentId is required for Parent learning results',
       ),
       _selectedPeriod = initialPeriod;

  final LearningResultRepository _repository;
  final LearningResultAudience audience;
  final int? studentId;

  LearningResultStatus _status = LearningResultStatus.idle;
  LearningResultReport? _report;
  LearningResultPeriod _selectedPeriod;
  int? _selectedAcademicYearId;
  String? _errorMessage;
  int _requestVersion = 0;

  LearningResultStatus get status => _status;
  LearningResultReport? get report => _report;
  LearningResultPeriod get selectedPeriod => _selectedPeriod;
  int? get selectedAcademicYearId => _selectedAcademicYearId;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == LearningResultStatus.loading;

  List<AcademicYearOption> get availableAcademicYears =>
      _report?.availableAcademicYears ?? const <AcademicYearOption>[];

  bool get canSelectOlderAcademicYear {
    final index = _selectedAcademicYearIndex;
    return index >= 0 && index < availableAcademicYears.length - 1;
  }

  bool get canSelectNewerAcademicYear => _selectedAcademicYearIndex > 0;

  Future<void> loadInitial() {
    return _loadResult(
      academicYearId: _selectedAcademicYearId,
      period: _selectedPeriod,
      useLatestFinalizedFallback: true,
    );
  }

  Future<void> retry() {
    return _loadResult(
      academicYearId: _selectedAcademicYearId,
      period: _selectedPeriod,
    );
  }

  Future<void> selectPeriod(LearningResultPeriod period) {
    if (_selectedPeriod == period && _report != null) {
      return Future<void>.value();
    }
    return _loadResult(academicYearId: _selectedAcademicYearId, period: period);
  }

  Future<void> selectAcademicYear(int academicYearId) {
    final isAvailable = availableAcademicYears.any(
      (year) => year.id == academicYearId,
    );
    if (!isAvailable || _selectedAcademicYearId == academicYearId) {
      return Future<void>.value();
    }
    return _loadResult(academicYearId: academicYearId, period: _selectedPeriod);
  }

  Future<void> selectOlderAcademicYear() {
    final index = _selectedAcademicYearIndex;
    if (index < 0 || index >= availableAcademicYears.length - 1) {
      return Future<void>.value();
    }
    return selectAcademicYear(availableAcademicYears[index + 1].id);
  }

  Future<void> selectNewerAcademicYear() {
    final index = _selectedAcademicYearIndex;
    if (index <= 0) {
      return Future<void>.value();
    }
    return selectAcademicYear(availableAcademicYears[index - 1].id);
  }

  Future<void> _loadResult({
    required int? academicYearId,
    required LearningResultPeriod period,
    bool useLatestFinalizedFallback = false,
  }) async {
    final requestVersion = ++_requestVersion;
    _selectedPeriod = period;
    _selectedAcademicYearId = academicYearId;
    _status = LearningResultStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedReport = switch (audience) {
        LearningResultAudience.parent =>
          await _repository.getParentStudentResult(
            studentId: studentId!,
            academicYearId: academicYearId,
            period: period,
          ),
        LearningResultAudience.student => await _repository.getStudentResult(
          academicYearId: academicYearId,
          period: period,
        ),
      };

      if (requestVersion != _requestVersion) {
        return;
      }

      if (useLatestFinalizedFallback &&
          !loadedReport.finalized &&
          loadedReport.availableAcademicYears.isNotEmpty) {
        final latestYearId = loadedReport.availableAcademicYears.first.id;
        if (latestYearId != loadedReport.academicYearId) {
          await _loadResult(academicYearId: latestYearId, period: period);
          return;
        }
      }

      _report = loadedReport;
      _selectedAcademicYearId = loadedReport.academicYearId;
      _selectedPeriod = loadedReport.period;
      _status = LearningResultStatus.success;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = LearningResultStatus.error;
      _errorMessage = _mapApiError(error);
      notifyListeners();
    } catch (_) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _status = LearningResultStatus.error;
      _errorMessage = 'Đã xảy ra lỗi khi tải kết quả học tập.';
      notifyListeners();
    }
  }

  int get _selectedAcademicYearIndex {
    final selectedId = _selectedAcademicYearId;
    if (selectedId == null) {
      return -1;
    }
    return availableAcademicYears.indexWhere((year) => year.id == selectedId);
  }

  String _mapApiError(ApiException error) {
    return switch (error.code) {
      'AUTH_SESSION_MISSING' =>
        'Phiên đăng nhập không tồn tại. Vui lòng đăng nhập lại.',
      'NETWORK_TIMEOUT' => 'Kết nối quá thời gian. Vui lòng thử lại.',
      'NETWORK_ERROR' =>
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      'FORBIDDEN' => 'Bạn không có quyền xem kết quả học tập này.',
      'RESOURCE_NOT_FOUND' ||
      'INTERNAL_SERVER_ERROR' => 'Chưa có dữ liệu năm học.',
      _ => error.message,
    };
  }
}
