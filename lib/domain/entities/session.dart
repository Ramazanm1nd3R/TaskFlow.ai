import 'package:taskflow_ai/domain/entities/user.dart';

class Session {
  const Session({
    required this.user,
    required this.expiresAt,
  });

  final User user;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
