import 'package:taskflow_ai/core/storage/secure_storage_service.dart';
import 'package:taskflow_ai/data/models/auth/session_model.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._storage);

  final SecureStorageService _storage;

  Future<SessionModel?> readSession() => _storage.readSession();

  Future<void> saveSession(SessionModel session) => _storage.saveSession(session);

  Future<void> clearSession() => _storage.clearSession();

  Future<void> savePendingVerification(Map<String, dynamic> payload) {
    return _storage.savePendingVerification(payload);
  }

  Future<Map<String, dynamic>?> readPendingVerification() {
    return _storage.readPendingVerification();
  }

  Future<void> savePendingAuthPayload(Map<String, dynamic> payload) {
    return _storage.savePendingAuthPayload(payload);
  }

  Future<Map<String, dynamic>?> readPendingAuthPayload() {
    return _storage.readPendingAuthPayload();
  }

  Future<void> clearPendingAuthFlow() => _storage.clearPendingAuthFlow();
}
