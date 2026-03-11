import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskflow_ai/data/models/auth/session_model.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _sessionKey = 'taskflow_session';
  static const _pendingVerificationKey = 'pending_verification';
  static const _pendingAuthPayloadKey = 'pending_auth_payload';

  Future<void> saveSession(SessionModel session) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<SessionModel?> readSession() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) return null;
    return SessionModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearSession() => _storage.delete(key: _sessionKey);

  Future<void> savePendingVerification(Map<String, dynamic> payload) {
    return _storage.write(
      key: _pendingVerificationKey,
      value: jsonEncode(payload),
    );
  }

  Future<Map<String, dynamic>?> readPendingVerification() async {
    final raw = await _storage.read(key: _pendingVerificationKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> savePendingAuthPayload(Map<String, dynamic> payload) {
    return _storage.write(
      key: _pendingAuthPayloadKey,
      value: jsonEncode(payload),
    );
  }

  Future<Map<String, dynamic>?> readPendingAuthPayload() async {
    final raw = await _storage.read(key: _pendingAuthPayloadKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearPendingAuthFlow() async {
    await _storage.delete(key: _pendingVerificationKey);
    await _storage.delete(key: _pendingAuthPayloadKey);
  }
}
