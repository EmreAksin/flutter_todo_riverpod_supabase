import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Utility class for error handling and user-friendly messages
class ErrorUtils {
  ErrorUtils._();

  /// Convert error object to user-friendly message
  static String getErrorMessage(Object? error) {
    if (error == null) return 'Unknown error occurred';

    if (error is AuthException) {
      return _parseAuthException(error);
    }

    if (error is PostgrestException) {
      return _parsePostgrestException(error);
    }

    if (error is Exception) {
      return _parseGeneralException(error);
    }

    final errorStr = error.toString().toLowerCase();

    // Network errors
    if (errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('socketexception') ||
        errorStr.contains('timeout')) {
      return 'Check your internet connection';
    }

    // Rate limiting
    if (errorStr.contains('too many requests') ||
        errorStr.contains('rate limit')) {
      return 'Too many attempts. Please wait and try again.';
    }

    // Permission errors
    if (errorStr.contains('permission') ||
        errorStr.contains('unauthorized') ||
        errorStr.contains('forbidden')) {
      return 'You do not have permission for this action';
    }

    // Not found errors
    if (errorStr.contains('not found') || errorStr.contains('404')) {
      return 'Content not found';
    }

    // Validation errors
    if (errorStr.contains('validation') || errorStr.contains('invalid')) {
      return 'Please check your input';
    }

    if (errorStr.contains('exception:')) {
      return error.toString().split('Exception:').last.trim();
    }

    return 'An error occurred. Please try again.';
  }

  /// Parse Supabase authentication exceptions
  static String _parseAuthException(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('email not confirmed') ||
        message.contains('confirm your email')) {
      return 'Please confirm your email';
    }

    if (message.contains('invalid login') ||
        message.contains('invalid credentials') ||
        message.contains('user not found')) {
      return 'Invalid email or password';
    }

    if (message.contains('weak password') ||
        message.contains('password should be')) {
      return 'Password must be at least 6 characters';
    }

    if (message.contains('user already registered') ||
        message.contains('email already exists')) {
      return 'This email is already registered';
    }

    if (message.contains('invalid email') || message.contains('valid email')) {
      return 'Please enter a valid email';
    }

    if (message.contains('session') ||
        message.contains('expired') ||
        message.contains('jwt')) {
      return 'Session expired. Please login again.';
    }

    return error.message.isNotEmpty
        ? error.message
        : 'Authentication error occurred';
  }

  /// Parse Supabase database exceptions
  static String _parsePostgrestException(PostgrestException error) {
    final message = error.message.toLowerCase();
    final code = error.code;

    if (code == '23503') return 'Related data not found';
    if (code == '23505') return 'This data already exists';
    if (code == '23502') return 'Please fill all required fields';
    if (code == '23514') return 'Invalid value entered';
    if (code == '42501') return 'Permission denied';
    if (code == '42P01') return 'Data source not found';

    if (message.contains('row-level security') || message.contains('rls')) {
      return 'Access denied to this data';
    }

    return error.message.isNotEmpty
        ? 'Database error: ${error.message}'
        : 'Database operation failed';
  }

  /// Parse general exceptions
  static String _parseGeneralException(Exception error) {
    final errorStr = error.toString().toLowerCase();

    if (error is FormatException) return 'Invalid data format';
    if (error is StateError) return 'Unexpected state error';
    if (error is ArgumentError) return 'Invalid parameter';

    if (errorStr.contains('timeout')) {
      return 'Operation timed out';
    }

    return error.toString().replaceAll('Exception:', '').trim();
  }

  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    Object? error, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    final message = getErrorMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange.shade700,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    Object? error, {
    String? title,
    List<Widget>? actions,
  }) async {
    if (!context.mounted) return;

    final message = getErrorMessage(error);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Error'),
        content: Text(message),
        actions:
            actions ??
            [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
      ),
    );
  }

  /// Retry mechanism for failed operations
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;

    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxAttempts) {
          rethrow;
        }

        // Exponential backoff
        await Future.delayed(delay * attempt);
      }
    }

    throw Exception('Maximum retry attempts reached');
  }

  /// Log error in debug mode
  static void logError(
    Object error,
    StackTrace? stackTrace, {
    String? message,
    Map<String, dynamic>? extra,
  }) {
    assert(() {
      debugPrint('═══════════════════════════════════════════');
      debugPrint('ERROR LOG - ${DateTime.now().toIso8601String()}');
      if (message != null) {
        debugPrint('Message: $message');
      }
      debugPrint('Error: $error');
      if (extra != null && extra.isNotEmpty) {
        debugPrint('Extra Info: $extra');
      }
      if (stackTrace != null) {
        debugPrint('Stack Trace:');
        debugPrint(stackTrace.toString());
      }
      debugPrint('═══════════════════════════════════════════');
      return true;
    }());
  }
}
