import 'package:taskflow_ai/data/models/auth/user_model.dart';
import 'package:taskflow_ai/domain/entities/session.dart';

class SessionModel extends Session {
  const SessionModel({
    required super.user,
    required super.expiresAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': (user as UserModel).toJson(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}
