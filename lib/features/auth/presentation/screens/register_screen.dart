import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_providers.dart';

/// Register screen
class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Text controllers
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();

    // Local loading state
    final isLoading = useState(false);

    // Listen to auth controller changes
    ref.listen(authControllerProvider, (previous, next) {
      isLoading.value = next.isLoading;

      if (next.hasError) {
        final errorMessage = _getErrorMessage(next.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (next.hasValue && next.value != null) {
        context.go('/todos');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading.value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: !isLoading.value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: !isLoading.value,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Passwords do not match'),
                            ),
                          );
                          return;
                        }

                        await ref
                            .read(authControllerProvider.notifier)
                            .signUp(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                            );
                      },
                child: isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('Sign Up'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: isLoading.value
                  ? null
                  : () {
                      context.pop();
                    },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }

  /// Get user-friendly error message
  String _getErrorMessage(Object? error) {
    if (error == null) return 'Unknown error occurred';

    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('user already registered') ||
        errorStr.contains('email already exists')) {
      return 'This email is already registered';
    }
    if (errorStr.contains('password') && errorStr.contains('short')) {
      return 'Password must be at least 6 characters';
    }
    if (errorStr.contains('invalid email')) {
      return 'Please enter a valid email';
    }
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Check your internet connection';
    }

    if (errorStr.contains('exception:')) {
      return error.toString().split('Exception:').last.trim();
    }

    return 'Sign up failed. Please try again.';
  }
}
