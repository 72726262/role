/// ✅ Validators
/// Input validation utilities

class Validators {
  /// Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  /// Password validator
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < minLength) {
      return 'كلمة المرور يجب أن تكون $minLength أحرف على الأقل';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    return null;
  }

  /// Required field validator
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    return null;
  }

  /// Phone number validator
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    final phoneRegex = RegExp(
      r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$',
    );
    if (!phoneRegex.hasMatch(value)) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  /// Min length validator
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    if (value.length < min) {
      final field = fieldName ?? 'هذا الحقل';
      return '$field يجب أن يكون $min أحرف على الأقل';
    }
    return null;
  }

  /// Max length validator
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      final field = fieldName ?? 'هذا الحقل';
      return '$field يجب ألا يتجاوز $max حرف';
    }
    return null;
  }

  /// Number validator
  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (double.tryParse(value) == null) {
      return 'يجب إدخال رقم صحيح';
    }
    return null;
  }

  /// Min value validator
  static String? minValue(String? value, double min) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'يجب إدخال رقم صحيح';
    }
    if (number < min) {
      return 'القيمة يجب أن تكون $min على الأقل';
    }
    return null;
  }

  /// Max value validator
  static String? maxValue(String? value, double max) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'يجب إدخال رقم صحيح';
    }
    if (number > max) {
      return 'القيمة يجب ألا تتجاوز $max';
    }
    return null;
  }

  /// URL validator
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرابط مطلوب';
    }
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'الرابط غير صحيح';
    }
    return null;
  }

  /// Match validator (for password confirmation)
  static String? match(String? value, String? matchValue, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    if (value != matchValue) {
      return fieldName != null ? '$fieldName غير متطابق' : 'القيم غير متطابقة';
    }
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Custom validator
  static String? custom(
    String? value,
    bool Function(String?) test,
    String errorMessage,
  ) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (!test(value)) {
      return errorMessage;
    }
    return null;
  }
}
