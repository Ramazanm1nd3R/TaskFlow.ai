import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_ai/core/utils/validators.dart';

void main() {
  test('email validator rejects invalid email', () {
    expect(validateEmail('abc'), isNotNull);
  });
}
