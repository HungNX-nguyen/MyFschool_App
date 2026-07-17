import 'dart:async';

class InactivitySessionController {
  InactivitySessionController({
    required Future<void> Function() onTimeout,
    this.timeout = const Duration(minutes: 30),
    DateTime Function()? now,
  }) : assert(timeout > Duration.zero),
       _onTimeout = onTimeout,
       _now = now ?? DateTime.now;

  final Duration timeout;
  final Future<void> Function() _onTimeout;
  final DateTime Function() _now;

  Timer? _timer;
  DateTime? _lastActivityAt;
  bool _isMonitoring = false;
  bool _isTimingOut = false;

  DateTime? get lastActivityAt => _lastActivityAt;
  bool get isMonitoring => _isMonitoring;

  void start() {
    _isMonitoring = true;
    _isTimingOut = false;
    _lastActivityAt = _now();
    _schedule(timeout);
  }

  void recordActivity() {
    if (!_isMonitoring || _isTimingOut) {
      return;
    }

    _lastActivityAt = _now();
    _schedule(timeout);
  }

  Future<void> checkForTimeout() async {
    final lastActivityAt = _lastActivityAt;
    if (!_isMonitoring || _isTimingOut || lastActivityAt == null) {
      return;
    }

    final elapsed = _now().difference(lastActivityAt);
    if (elapsed >= timeout) {
      await _triggerTimeout();
      return;
    }

    final remaining = timeout - elapsed;
    _schedule(remaining > Duration.zero ? remaining : Duration.zero);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _lastActivityAt = null;
    _isMonitoring = false;
    _isTimingOut = false;
  }

  void dispose() {
    stop();
  }

  void _schedule(Duration duration) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      unawaited(checkForTimeout());
    });
  }

  Future<void> _triggerTimeout() async {
    if (!_isMonitoring || _isTimingOut) {
      return;
    }

    _timer?.cancel();
    _timer = null;
    _isMonitoring = false;
    _isTimingOut = true;
    try {
      await _onTimeout();
    } finally {
      _isTimingOut = false;
    }
  }
}
