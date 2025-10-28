import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_providers.dart';

/// Login screen
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Text controllers for email and password
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    // Local loading state
    final isLoading = useState(false);

    // Listen to auth controller changes
    ref.listen<AsyncValue<UserEntity?>>(authControllerProvider, (
      previous,
      next,
    ) {
      isLoading.value = next.isLoading;

      if (next.hasError) {
        ErrorUtils.showErrorSnackBar(context, next.error);
      }

      if (next.hasValue && next.value != null) {
        context.go('/todos');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
            const SizedBox(height: 24),
            LoadingButton(
              isFullWidth: true,
              isLoading: isLoading.value,
              text: 'Login',
              loadingText: 'Logging in...',
              icon: Icons.login,
              onPressed: () async {
                if (emailController.text.trim().isEmpty) {
                  ErrorUtils.showWarningSnackBar(
                    context,
                    'Email cannot be empty',
                  );
                  return;
                }
                if (passwordController.text.isEmpty) {
                  ErrorUtils.showWarningSnackBar(
                    context,
                    'Password cannot be empty',
                  );
                  return;
                }

                await ref
                    .read(authControllerProvider.notifier)
                    .signIn(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                    );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: isLoading.value
                  ? null
                  : () {
                      context.push('/register');
                    },
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
