import '../entities/user_entity.dart';

/// Authentication repository interface
/// Defines what auth operations are available
abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;

  /// Sign up new user with email and password
  Future<UserEntity> signUp({required String email, required String password});

  /// Sign in existing user
  Future<UserEntity> signIn({required String email, required String password});

  /// Sign out current user
  Future<void> signOut();

  /// Get current authenticated user
  Future<UserEntity?> getCurrentUser();
}
