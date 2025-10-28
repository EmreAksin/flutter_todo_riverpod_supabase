import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/todos/presentation/screens/todo_screen.dart';

part 'app_router.g.dart';

/// App router configuration with authentication guard
@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      return authState.when(
        data: (user) {
          final isLoggedIn = user != null;
          final isGoingToLogin = state.matchedLocation == '/login';
          final isGoingToRegister = state.matchedLocation == '/register';

          // Redirect to login if not authenticated
          if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
            return '/login';
          }

          // Redirect to todos if already authenticated
          if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
            return '/todos';
          }

          return null;
        },
        loading: () => null,
        error: (error, stackTrace) => '/login',
      );
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: const LoginScreen());
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const RegisterScreen(),
          );
        },
      ),
      GoRoute(
        path: '/todos',
        name: 'todos',
        pageBuilder: (context, state) {
          return MaterialPage(key: state.pageKey, child: const TodosScreen());
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Page not found!'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
