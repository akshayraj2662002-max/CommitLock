import 'package:flutter/material.dart';
import '../../data/datasources/hive_datasource.dart';
import '../../data/models/session_model.dart';

class HistoryProvider extends ChangeNotifier {
  final HiveDataSource _hiveDataSource;

  List<SessionModel> _sessions = [];
  String _filter = 'All';
  String _sort = 'Newest';

  HistoryProvider(this._hiveDataSource) {
    loadSessions();
  }

  List<SessionModel> get sessions => _filteredAndSortedSessions;
  String get filter => _filter;
  String get sort => _sort;

  int get totalSessions =>
      _sessions.where((s) => s.status != 'active').length;
  int get completedSessions =>
      _sessions.where((s) => s.status == 'completed').length;
  int get brokenSessions =>
      _sessions.where((s) => s.status == 'broken').length;

  double get successRate {
    final finished = _sessions.where((s) => s.status != 'active').length;
    if (finished == 0) return 0;
    return completedSessions / finished * 100;
  }

  int get totalCommittedMinutes {
    int total = 0;
    for (var s in _sessions.where((s) => s.status != 'active')) {
      total += s.plannedDurationMinutes;
    }
    return total;
  }

  List<SessionModel> get _filteredAndSortedSessions {
    List<SessionModel> result = _sessions.where((s) => s.status != 'active').toList();

    if (_filter == 'Completed') {
      result = result.where((s) => s.status == 'completed').toList();
    } else if (_filter == 'Broken') {
      result = result.where((s) => s.status == 'broken').toList();
    }

    if (_sort == 'Newest') {
      result.sort((a, b) => b.startTimestamp.compareTo(a.startTimestamp));
    } else {
      result.sort((a, b) => a.startTimestamp.compareTo(b.startTimestamp));
    }

    return result;
  }

  void loadSessions() {
    _sessions = _hiveDataSource.getAllSessions();
    notifyListeners();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSort(String sort) {
    _sort = sort;
    notifyListeners();
  }

  Future<void> clearAllHistory() async {
    await _hiveDataSource.clearAllSessions();
    _sessions = [];
    notifyListeners();
  }
}
