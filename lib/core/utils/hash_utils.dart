import 'dart:convert';

import 'package:crypto/crypto.dart';

String stableHash(Map<String, Object?> payload) {
  final normalized = jsonEncode(payload);
  return sha1.convert(utf8.encode(normalized)).toString();
}
