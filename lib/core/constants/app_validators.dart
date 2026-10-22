import '../constants/app_regex.dart';

class AppValidators {
  AppValidators._();

  // For email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!AppRegex.emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  // For password
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!AppRegex.passwordRegex.hasMatch(value)) {
      return 'Password must have at least one uppercase letter and one number';
    }
    return null;
  }

  // For confirm password
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  // For full name
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (!AppRegex.fullNameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters';
    }
    return null;
  }

  // For mobile number ( Sri lankan format )
  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    if (!AppRegex.mobileNumberRegex.hasMatch(value.trim())) {
      return 'Enter a valid mobile number (e.g. 0771234567)';
    }
    return null;
  }
}