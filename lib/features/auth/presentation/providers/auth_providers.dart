import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

/// Provider for auth remote data source
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRemoteDataSourceImpl(supabaseClient);
}

/// Provider for auth repository
@riverpod
AuthRepository authRepository(Ref ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
}

/// Provider for auth state changes stream
@riverpod
Stream<UserEntity?> authStateChanges(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
}

/// Provider for current user
@riverpod
Future<UserEntity?> currentUser(Ref ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
}

/// Auth controller for sign in/up/out operations
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<UserEntity?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    return repository.getCurrentUser();
  }

  /// Sign up new user
  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signUp(email: email, password: password);

      if (!ref.mounted) return user;

      ref.invalidate(authStateChangesProvider);
      ref.invalidate(currentUserProvider);

      return user;
    });
  }

  /// Sign in existing user
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signIn(email: email, password: password);

      if (!ref.mounted) return user;

      ref.invalidate(authStateChangesProvider);
      ref.invalidate(currentUserProvider);

      return user;
    });
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();

      if (!ref.mounted) return;

      state = const AsyncValue.data(null);

      ref.invalidate(authStateChangesProvider);
      ref.invalidate(currentUserProvider);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;

      state = AsyncValue.error(error, stackTrace);
    }
  }
}
