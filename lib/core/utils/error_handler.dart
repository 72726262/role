import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🐛 Error Handler
/// Centralized error handling for the application

class ErrorHandler {
  /// Handle any error
  static String handleError(dynamic error) {
    if (kDebugMode) {
      print('Error occurred: $error');
    }

    // Supabase errors
    if (error is AuthException) {
      return _handleAuthError(error);
    }

    if (error is PostgrestException) {
      return _handlePostgrestError(error);
    }

    if (error is StorageException) {
      return _handleStorageError(error);
    }

    // Network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('HandshakeException')) {
      return 'خطأ في الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال. تحقق من اتصال الإنترنت وحاول مرة أخرى';
    }

    // Format errors
    if (error is FormatException) {
      return 'خطأ في تنسيق البيانات';
    }

    // Type errors
    if (error is TypeError) {
      return 'خطأ في نوع البيانات';
    }

    // Generic error
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
  }

  /// Handle authentication errors
  static String _handleAuthError(AuthException error) {
    switch (error.statusCode) {
      case '400':
        if (error.message.contains('Invalid login credentials')) {
          return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        }
        if (error.message.contains('Email not confirmed')) {
          return 'يرجى تأكيد بريدك الإلكتروني أولاً';
        }
        return 'بيانات تسجيل الدخول غير صحيحة';

      case '422':
        if (error.message.contains('User already registered')) {
          return 'هذا البريد الإلكتروني مسجل بالفعل';
        }
        return 'البيانات المدخلة غير صالحة';

      case '429':
        return 'عدد كبير من المحاولات. يرجى الانتظار قليلاً';

      case '500':
        return 'خطأ في الخادم. يرجى المحاولة لاحقاً';

      default:
        return error.message;
    }
  }

  /// Handle database errors
  static String _handlePostgrestError(PostgrestException error) {
    final code = error.code;
    final message = error.message;

    // Unique constraint violation
    if (code == '23505') {
      return 'هذا العنصر موجود بالفعل';
    }

    // Foreign key violation
    if (code == '23503') {
      return 'لا يمكن حذف هذا العنصر لأنه مرتبط بعناصر أخرى';
    }

    // Not null violation
    if (code == '23502') {
      return 'يجب إدخال جميع الحقول المطلوبة';
    }

    // Permission denied
    if (code == '42501') {
      return 'ليس لديك صلاحية للقيام بهذا الإجراء';
    }

    // Row level security
    if (message.contains('row-level security')) {
      return 'ليس لديك صلاحية الوصول إلى هذا العنصر';
    }

    return message;
  }

  /// Handle storage errors
  static String _handleStorageError(StorageException error) {
    final message = error.message;

    if (message.contains('not found')) {
      return 'الملف غير موجود';
    }

    if (message.contains('size')) {
      return 'حجم الملف كبير جداً';
    }

    if (message.contains('type')) {
      return 'نوع الملف غير مدعوم';
    }

    if (message.contains('permission')) {
      return 'ليس لديك صلاحية رفع الملفات';
    }

    return message;
  }

  /// Log error for debugging
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('═══════════════════════════════════');
      print('ERROR: $error');
      if (stackTrace != null) {
        print('STACK TRACE:');
        print(stackTrace);
      }
      print('═══════════════════════════════════');
    }
  }

  /// Get user-friendly message
  static String getUserMessage(dynamic error) {
    return handleError(error);
  }

  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    return error.toString().contains('SocketException') ||
        error.toString().contains('HandshakeException') ||
        error.toString().contains('TimeoutException');
  }

  /// Check if error is authentication related
  static bool isAuthError(dynamic error) {
    return error is AuthException;
  }

  /// Check if error is permission related
  static bool isPermissionError(dynamic error) {
    if (error is PostgrestException) {
      return error.code == '42501' ||
          error.message.contains('row-level security');
    }
    return false;
  }
}
