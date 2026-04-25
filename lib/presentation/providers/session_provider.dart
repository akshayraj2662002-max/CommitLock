import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/hive_datasource.dart';
import '../../data/datasources/prefs_datasource.dart';
import '../../data/models/session_model.dart';

class SessionProvider extends ChangeNotifier with WidgetsBindingObserver {
  final HiveDataSource _hiveDataSource;
  final PrefsDataSource _prefsDataSource;

  SessionModel? _activeSession;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  String _currentQuote = '';
  int _quoteIndex = 0;

  final List<String> _quotes = [
    "Stay focused. Every second counts! 🔥",
    "You're building something great. 💪",
    "Discipline beats motivation. 🎯",
    "The pain of discipline weighs ounces, regret weighs tons. ⚖️",
    "Your future self will thank you. 🌟",
    "Don't break the chain. Keep going! 🔗",
    "Small steps lead to big results. 📈",
    "Commitment transforms promises into reality. ✨",
    "You're stronger than you think. 💎",
    "Success is small efforts repeated daily. 🏆",
  ];

  SessionProvider(this._hiveDataSource, this._prefsDataSource) {
    WidgetsBinding.instance.addObserver(this);
    _currentQuote = _quotes[0];
    _checkForActiveSession();
  }

  SessionModel? get activeSession => _activeSession;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  String get currentQuote => _currentQuote;
  double get progress =>
      _totalSeconds > 0 ? 1.0 - (_remainingSeconds / _totalSeconds) : 0.0;
  int get streakCount => _prefsDataSource.streakCount;

  String get formattedTime {
    int mins = _remainingSeconds ~/ 60;
    int secs = _remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  bool get hasActiveSession => _activeSession != null;

  void _checkForActiveSession() {
    final active = _hiveDataSource.getActiveSession();
    if (active != null) {
      _activeSession = active;
      _totalSeconds = active.plannedDurationMinutes * 60;
      _recalculateRemainingTime();
      if (_remainingSeconds > 0) {
        _startTimer();
      } else {
        _completeSession();
      }
    }
  }

  void _recalculateRemainingTime() {
    if (_activeSession == null) return;
    final elapsed =
        DateTime.now().difference(_activeSession!.startTimestamp).inSeconds;
    final total = _activeSession!.plannedDurationMinutes * 60;
    _remainingSeconds = (total - elapsed).clamp(0, total);
    _totalSeconds = total;
  }

  Future<SessionModel> startSession({
    required String habitCategory,
    required int durationMinutes,
    required double penaltyAmount,
    required String restrictionLevel,
    required List<String> blockedCategories,
  }) async {
    final session = SessionModel(
      id: const Uuid().v4(),
      habitCategory: habitCategory,
      plannedDurationMinutes: durationMinutes,
      startTimestamp: DateTime.now(),
      status: 'active',
      penaltyAmount: penaltyAmount,
      restrictionLevel: restrictionLevel,
      blockedCategories: blockedCategories,
    );

    await _hiveDataSource.saveSession(session);
    _activeSession = session;
    _totalSeconds = durationMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _quoteIndex = 0;
    _currentQuote = _quotes[0];
    _startTimer();
    notifyListeners();
    return session;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _completeSession();
        return;
      }
      _remainingSeconds--;

      // Rotate quote every 30 seconds
      if (_remainingSeconds % 30 == 0) {
        _quoteIndex = (_quoteIndex + 1) % _quotes.length;
        _currentQuote = _quotes[_quoteIndex];
      }

      // Update actual duration
      if (_activeSession != null) {
        _activeSession!.actualDurationSeconds =
            _totalSeconds - _remainingSeconds;
      }

      notifyListeners();
    });
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    if (_activeSession != null) {
      _activeSession!.status = 'completed';
      _activeSession!.endTimestamp = DateTime.now();
      _activeSession!.actualDurationSeconds = _totalSeconds;
      await _hiveDataSource.saveSession(_activeSession!);
      await _prefsDataSource.incrementStreak();
    }
    notifyListeners();
  }

  Future<void> breakSession() async {
    _timer?.cancel();
    if (_activeSession != null) {
      _activeSession!.status = 'broken';
      _activeSession!.endTimestamp = DateTime.now();
      _activeSession!.actualDurationSeconds =
          _totalSeconds - _remainingSeconds;
      await _hiveDataSource.saveSession(_activeSession!);
      await _prefsDataSource.resetStreak();
    }
    notifyListeners();
  }

  SessionModel? finishAndGetResult() {
    final result = _activeSession;
    _activeSession = null;
    _remainingSeconds = 0;
    _totalSeconds = 0;
    notifyListeners();
    return result;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _activeSession != null) {
      _recalculateRemainingTime();
      if (_remainingSeconds <= 0) {
        _completeSession();
      } else {
        _startTimer();
      }
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  int getTodayCompletedMinutes() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final sessions = _hiveDataSource.getAllSessions();
    int total = 0;
    for (var s in sessions) {
      if (s.status == 'completed' && s.startTimestamp.isAfter(todayStart)) {
        total += s.actualDurationSeconds;
      }
    }
    return total ~/ 60;
  }

  int getTodayCommittedMinutes() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final sessions = _hiveDataSource.getAllSessions();
    int total = 0;
    for (var s in sessions) {
      if (s.startTimestamp.isAfter(todayStart)) {
        total += s.plannedDurationMinutes;
      }
    }
    return total;
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
