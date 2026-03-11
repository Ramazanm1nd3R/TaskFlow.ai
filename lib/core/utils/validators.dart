String? requiredField(String? value, {String label = 'Field'}) {
  if (value == null || value.trim().isEmpty) {
    return '$label is required';
  }
  return null;
}

String? validateEmail(String? value) {
  final required = requiredField(value, label: 'Email');
  if (required != null) return required;
  final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  if (!regex.hasMatch(value!.trim())) {
    return 'Enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  final required = requiredField(value, label: 'Password');
  if (required != null) return required;
  if (value!.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}
