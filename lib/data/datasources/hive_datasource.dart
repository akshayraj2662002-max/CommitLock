import 'package:hive_flutter/hive_flutter.dart';
import '../models/session_model.dart';

class HiveDataSource {
  static const String _sessionBoxName = 'sessions';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SessionModelAdapter());
    await Hive.openBox<SessionModel>(_sessionBoxName);
  }

  Box<SessionModel> get _sessionBox => Hive.box<SessionModel>(_sessionBoxName);

  Future<void> saveSession(SessionModel session) async {
    await _sessionBox.put(session.id, session);
  }

  SessionModel? getSession(String id) {
    return _sessionBox.get(id);
  }

  List<SessionModel> getAllSessions() {
    return _sessionBox.values.toList();
  }

  SessionModel? getActiveSession() {
    try {
      return _sessionBox.values.firstWhere((s) => s.status == 'active');
    } catch (e) {
      return null;
    }
  }

  Future<void> updateSession(SessionModel session) async {
    await session.save();
  }

  Future<void> deleteSession(String id) async {
    await _sessionBox.delete(id);
  }

  Future<void> clearAllSessions() async {
    await _sessionBox.clear();
  }
}
